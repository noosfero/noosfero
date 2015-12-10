require_dependency 'environment'

class Environment
  settings_items :piwik_domain
  settings_items :piwik_path, :default => 'piwik'
  settings_items :piwik_site_id
  attr_accessible :piwik_domain, :piwik_site_id, :piwik_path
end
