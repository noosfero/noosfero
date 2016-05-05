require_dependency 'environment'

class Environment
  has_many :notifications, class_name: 'AdminNotificationsPlugin::Notification', :as => :target
end
