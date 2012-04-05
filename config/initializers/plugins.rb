require 'noosfero/plugin'
require 'noosfero/plugin/manager'
require 'noosfero/plugin/context'
require 'noosfero/plugin/active_record'
require 'noosfero/plugin/mailer_base'
Noosfero::Plugin.init_system if $NOOSFERO_LOAD_PLUGINS
