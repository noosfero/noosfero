require_dependency 'comment'

class Comment
  settings_items :mailing_list_plugin_uuid, :type => 'string'
  settings_items :mailing_list_plugin_from_list, :type => 'boolean', :default => false
  attr_accessible :mailing_list_plugin_uuid, :mailing_list_plugin_from_list
end
