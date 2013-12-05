require 'noosfero/plugin'
require 'noosfero/plugin/hot_spot'
require 'noosfero/plugin/manager'
require 'noosfero/plugin/active_record'
require 'noosfero/plugin/mailer_base'
require 'noosfero/plugin/settings'
require 'noosfero/plugin/spammable'
Noosfero::Plugin.init_system if $NOOSFERO_LOAD_PLUGINS

if Rails.env == 'development' && $NOOSFERO_LOAD_PLUGINS
  ActionController::Base.send(:prepend_before_filter) do |controller|
    Noosfero::Plugin.init_system
  end
end
