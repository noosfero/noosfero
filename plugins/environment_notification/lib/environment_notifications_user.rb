class EnvironmentNotificationsUser < ActiveRecord::Base
  self.table_name = "environment_notifications_users"

  belongs_to :user
  belongs_to :environment_notification, class_name: 'EnvironmentNotificationPlugin::EnvironmentNotification'

  attr_accessible :user_id, :environment_notification_id

  validates_uniqueness_of :user_id, :scope => :environment_notification_id
end
