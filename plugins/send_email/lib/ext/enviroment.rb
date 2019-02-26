require_dependency 'environment'

class Environment
  settings_items :send_email_plugin_allow_to
  attr_accessible :send_email_plugin_allow_to
end

