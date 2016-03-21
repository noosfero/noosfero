require_dependency 'user'

class User
  has_many :notifications_users, :class_name => 'AdminNotificationsPlugin::NotificationsUser'
  has_many :notifications, :through => :notifications_users
end
