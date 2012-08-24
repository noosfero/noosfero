require 'noosfero/plugin'
require 'noosfero/plugin/acts_as_having_hotspots'
require 'noosfero/plugin/manager'
require 'noosfero/plugin/active_record'
require 'noosfero/plugin/mailer_base'
Noosfero::Plugin.init_system if $NOOSFERO_LOAD_PLUGINS
