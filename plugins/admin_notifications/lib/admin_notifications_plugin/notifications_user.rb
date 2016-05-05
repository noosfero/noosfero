class AdminNotificationsPlugin::NotificationsUser < ActiveRecord::Base
  self.table_name = "admin_notifications_plugin_notifications_users"

  belongs_to :user
  belongs_to :notification, class_name: 'AdminNotificationsPlugin::Notification'

  attr_accessible :user_id, :notification_id

  validates_uniqueness_of :user_id, :scope => :notification_id
end
