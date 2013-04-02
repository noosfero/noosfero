require 'noosfero/plugin'
require 'noosfero/plugin/hot_spot'
require 'noosfero/plugin/manager'
require 'noosfero/plugin/active_record'
require 'noosfero/plugin/mailer_base'
require 'noosfero/plugin/settings'
Noosfero::Plugin.init_system if $NOOSFERO_LOAD_PLUGINS
