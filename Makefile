# dcape-app-redmine Makefile
# the Makefile config and start special docker image with redmine3.4.4, plugins, passenger5.1.12 as a service with docker-compose for dcape server

# broken installations plugins: issues_tree smart_issues_sort postgresql_search
#smart_issues_sort last commit more 3 years later
#vote_on_issue install ok, but not vork - have syntx error with database work
# tags and redmineup_tags - conflicted, must install only one, now select redmineup_tags becouse other plugins from redmineup.com use


SHELL               = /bin/bash
CFG                ?= .env

# Database name
DB_NAME            ?= redmine
# Database user name
DB_USER            ?= $(DB_NAME)
# Database user password
DB_PASS            ?= $(shell < /dev/urandom tr -dc A-Za-z0-9 | head -c14; echo)
# Database dump for import on create
DB_SOURCE          ?=

# Site host
APP_SITE           ?= rm.dev.lan

PLUGINS_PATH       ?= plugins

#Plugin list for instal if redmine start first time (the name of the plugin must the same as the name of the plugin directory in the image)
PLUGINS_LIST=sidebar_hide redmine_fixed_header redmine_drawio redmine_wiki_lists \
 redmine_theme_changer redmine_user_specific_theme view_customize \
 redmine_wiki_extensions issue_id redmine_issue_todo_lists redhopper

# Docker image name
IMAGE              ?= dopos/redmine
# Docker image tag
IMAGE_VER          ?= 0.2
# Docker-compose project name (container name prefix)
PROJECT_NAME       ?= rm
# dcape container name prefix
DCAPE_PROJECT_NAME ?= dcape
# dcape network attach to
DCAPE_NET          ?= $(DCAPE_PROJECT_NAME)_default
# dcape postgresql container name
DCAPE_DB           ?= $(DCAPE_PROJECT_NAME)_db_1

# set to true for need update exist or install new plugins without remove existing plugins
REDMINE_PLUGINS_UPDATE_ENV ?=

#environments for SMTP email configuration
REDMINE_EMAIL_DELIVERY_METHOD = :smtp
REDMINE_EMAIL_ADDRESS         = localhost
REDMINE_EMAIL_PORT            = 25
REDMINE_EMAIL_AUTHENTICATION  = :login
REDMINE_EMAIL_DOMAIN          = localhost
REDMINE_EMAIL_USER_NAME       =
REDMINE_EMAIL_PASSWORD        =

# Docker-compose image tag
DC_VER             ?= 1.14.0

define CONFIG_DEF
# ------------------------------------------------------------------------------
# Mattermost settings

# Site host
APP_SITE=$(APP_SITE)

# Database name
DB_NAME=$(DB_NAME)
# Database user name
DB_USER=$(DB_USER)
# Database user password
DB_PASS=$(DB_PASS)
# Database dump for import on create
DB_SOURCE=$(DB_SOURCE)

# Docker details

# Docker image name
IMAGE=$(IMAGE)
# Docker image tag
IMAGE_VER=$(IMAGE_VER)
# Docker-compose project name (container name prefix)
PROJECT_NAME=$(PROJECT_NAME)
# dcape network attach to
DCAPE_NET=$(DCAPE_NET)
# dcape postgresql container name
DCAPE_DB=$(DCAPE_DB)

# Plugins list
PLUGINS_LIST=$(PLUGINS_LIST)

#environments for SMTP email configuration
REDMINE_EMAIL_DELIVERY_METHOD=$(REDMINE_EMAIL_DELIVERY_METHOD)
REDMINE_EMAIL_ADDRESS=$(REDMINE_EMAIL_ADDRESS)
REDMINE_EMAIL_PORT=$(REDMINE_EMAIL_PORT)
REDMINE_EMAIL_AUTHENTICATION=$(REDMINE_EMAIL_AUTHENTICATION)
REDMINE_EMAIL_DOMAIN=$(REDMINE_EMAIL_DOMAIN)
REDMINE_EMAIL_USER_NAME=$(REDMINE_EMAIL_USER_NAME)
REDMINE_EMAIL_PASSWORD=$(REDMINE_EMAIL_PASSWORD)

endef
export CONFIG_DEF

-include $(CFG)
export

.PHONY: all $(CFG) start start-hook stop update up reup down docker-wait db-create db-drop psql dc help

all: help

# ------------------------------------------------------------------------------
# webhook commands
start: db-create up

start-hook: db-create reup

stop: down

update: reup

# ------------------------------------------------------------------------------
# docker commands
## старт контейнеров
up:
up: CMD=up -d
up: dc

## рестарт контейнеров
reup:
reup: CMD=up --force-recreate -d
reup: dc

## остановка и удаление всех контейнеров
down:
down: CMD=down -v
down: dc

# Wait for postgresql container start
docker-wait:
	@echo -n "Checking PG is ready..."
	@until [[ `docker inspect -f "{{.State.Health.Status}}" $$DCAPE_DB` == healthy ]] ; do sleep 1 ; echo -n "." ; done
	@echo "Ok"

# ------------------------------------------------------------------------------
# DB operations

# Database import script
# DCAPE_DB_DUMP_DEST must be set in pg container

define IMPORT_SCRIPT
[[ "$$DCAPE_DB_DUMP_DEST" ]] || { echo "DCAPE_DB_DUMP_DEST not set. Exiting" ; exit 1 ; } ; \
DB_NAME="$$1" ; DB_USER="$$2" ; DB_PASS="$$3" ; DB_SOURCE="$$4" ; \
dbsrc=$$DCAPE_DB_DUMP_DEST/$$DB_SOURCE.tgz ; \
if [ -f $$dbsrc ] ; then \
  echo "Dump file $$dbsrc found, restoring database..." ; \
  zcat $$dbsrc | PGPASSWORD=$$DB_PASS pg_restore -h localhost -U $$DB_USER -O -Ft -d $$DB_NAME || exit 1 ; \
else \
  echo "Dump file $$dbsrc not found" ; \
  exit 2 ; \
fi
endef
export IMPORT_SCRIPT

# create user, db and load dump
# check DATABASE exist and set of docker-compose.yml variable via .env
db-create: docker-wait
	@echo "*** $@ ***" ; \
	docker exec -i $$DCAPE_DB psql -U postgres -c "CREATE USER \"$$DB_USER\" WITH PASSWORD '$$DB_PASS';" || true ; \
	docker exec -i $$DCAPE_DB psql -U postgres -c "CREATE DATABASE \"$$DB_NAME\" OWNER \"$$DB_USER\";" || db_exists=1 ; \
	if [[ ! "$$db_exists" ]] ; then \
	  if [[ "$$DB_SOURCE" ]] ; then \
	    echo "$$IMPORT_SCRIPT" | docker exec -i $$DCAPE_DB bash -s - $$DB_NAME $$DB_USER $$DB_PASS $$DB_SOURCE \
	    && docker exec -i $$DCAPE_DB psql -U postgres -c "COMMENT ON DATABASE \"$$DB_NAME\" IS 'SOURCE $$DB_SOURCE';" \
	    || true ; \
	  fi  \
	fi

## drop database and user
db-drop: docker-wait
	@echo "*** $@ ***"
	@docker exec -i $$DCAPE_DB psql -U postgres -c "DROP DATABASE \"$$DB_NAME\";" || true
	@docker exec -i $$DCAPE_DB psql -U postgres -c "DROP USER \"$$DB_USER\";" || true

# ------------------------------------------------------------------------------
# $$PWD используется для того, чтобы текущий каталог был доступен в контейнере по тому же пути
# и относительные тома новых контейнеров могли его использовать
## run docker-compose
dc: docker-compose.yml
	@docker run --rm  \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  -v $$PWD:$$PWD \
	  -w $$PWD \
	  docker/compose:$(DC_VER) \
	  -p $$PROJECT_NAME \
	  $(CMD)


$(CFG):
	@[ -f $@ ] || { echo "$$CONFIG_DEF" > $@ ; echo "Warning: Created default $@" ; }

# ------------------------------------------------------------------------------

## List Makefile targets
help:
	@grep -A 1 "^##" Makefile | less

##
## Press 'q' for exit
##
