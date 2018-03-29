# dcape-app-redmine

[![GitHub Release][1]][2] [![GitHub code size in bytes][3]]() [![GitHub license][4]][5]

[1]: https://img.shields.io/github/release/dopos/dcape-app-redmine.svg
[2]: https://github.com/dopos/dcape-app-redmine/releases
[3]: https://img.shields.io/github/languages/code-size/dopos/dcape-app-redmine.svg
[4]: https://img.shields.io/github/license/dopos/dcape-app-redmine.svg
[5]: LICENSE

[Redmine](https://en.wikipedia.org/wiki/Redmine) application configuration for set: plugins, passenger, configured postgresql backend for automated deploy of [dcape](https://github.com/dopos/dcape).

## Docker image used

* [redmine](https://hub.docker.com/r/abhinand12/redmine3.4-plugins-passenger/) special builded image

## Requirements

* linux 64bit (git, make, wget, gawk, openssl)
* [docker](http://docker.io)
* [dcape](https://github.com/dopos/dcape)
* Git service ([github](https://github.com), [gitea](https://gitea.io) or [gogs](https://gogs.io))

## Usage

* Fork this repo in your Git service
* Setup deploy hook
* Run "Test delivery" (config sample will be created in dcape)
* Edit and save config (enable deploy etc)
* Run "Test delivery" again (app will be installed and started on webhook host)

## This version contains plugins, some of which require configuration

* [zenedit](https://www.redmineup.com/pages/plugins/zenedit) - don't require configuration
* [theme_changer](http://www.redmine.org/plugins/redmine_theme_changer) - don't require configuration
* [unread_issues](http://www.redmine.org/plugins/unread_issues)	- configurable plugin, create public query and add for plugin configuration
* [user_specific_theme](http://www.redmine.org/plugins/redmine_user_specific_theme) - don't require configuration
* [view_customize](http://www.redmine.org/plugins/redmine_view_customize) - don't require configuration, add customize for needed
* [wiki_lists](http://www.redmine.org/plugins/redmine_wiki_lists)	- don't require configuration
* [wiki_extensions](http://www.redmine.org/plugins/redmine_wiki_extensions)	- don't require configuration
* [sidebar_hide](http://www.redmine.org/plugins/sidebar_hide)	- don't require configuration
* [issue_tabs](http://www.redmine.org/plugins/redmine_issue_tabs)	- don't require configuration
* [issue_id](http://www.redmine.org/plugins/issue_id)	- don't require configuration
* [fixed_header](http://www.redmine.org/plugins/redmine-fixed-header)	- don't require configuration
* [drawio](http://www.redmine.org/plugins/redmine_drawio) - don't require configuration
* [issue_todo_list](http://www.redmine.org/plugins/redmine_issue_todo_lists)	- don't require configuration
* [wbs_plugin](http://www.redmine.org/plugins/wbs-plugin) - Enable REST API on settings
* [easy_mindmup](http://www.redmine.org/plugins/mindmap-plugin)	- Enable REST API on settings
* [a_common_libs](http://www.redmine.org/plugins/a_common_libs) - configurable plugin, check for enable -"Auto enabling of necessary libraries"
* [usability](http://www.redmine.org/plugins/usability)	- configurable plugin, set some options, load icons
* [redmineup_tags](http://www.redmine.org/plugins/redmineup_tags)	- configurable plugin, set options, for configure tags view
* [redhopper](http://www.redmine.org/plugins/redhopper)	- configurable plugin, set some options, if need.

## Plugins recomendations

* rmplus.pro plugins (unread_issues, usability, a_common_libs) recomend to use Redmine skin - [Redmine Alex Skin](https://bitbucket.org/dkuk/redmine_alex_skin.git), but its use is not necessary.


See also: [Deploy setup](https://github.com/dopos/dcape/blob/master/DEPLOY.md) (in Russian)

## License

The MIT License (MIT), see [LICENSE](LICENSE).

2018 Maxim Danilin <zan@whiteants.net>
