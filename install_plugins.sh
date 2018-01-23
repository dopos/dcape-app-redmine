#!/bin/bash
# Redmine plugins install script
# Usage:
#   make plugins

db_init() {
  local dest=$1
  cat > ../config/database.yml <<EOF
# PostgreSQL configuration example
production:
  adapter: postgresql
  database: ${REDMINE_DB_DATABASE}
  host: ${REDMINE_DB_POSTGRES}
  username: ${REDMINE_DB_USERNAME}
  password: "${REDMINE_DB_PASSWORD}"
EOF
}

# ------------------------------------------------------------------------------

plugin_tags() {
  git clone https://github.com/ixti/redmine_tags.git
  cd redmine_tags
  bundle install
  rake redmine:plugins:migrate NAME=redmine_tags RAILS_ENV=production
  cd ..
}

# ------------------------------------------------------------------------------

cd /usr/src/redmine/plugins
[ -f ../config/database.yml ] || db_init ../config/database.yml

for p in $@ ; do
  echo "Installing plugin $p..."
  case "$p" in
    tags)
	plugin_tags
	;;
    *)
	echo "Error: Unknown plugin name"
	;;
  esac
  echo "Done"
done

rm ../config/database.yml
