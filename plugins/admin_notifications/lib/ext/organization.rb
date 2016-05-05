require_dependency 'organization'

class Organization
  has_many :notifications, class_name: 'AdminNotificationsPlugin::Notification', :as => :target
end
