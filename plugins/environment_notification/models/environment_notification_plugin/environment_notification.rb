class EnvironmentNotificationPlugin::EnvironmentNotification < ActiveRecord::Base

  self.table_name = "environment_notifications"

  TYPE_LIST = [
    "EnvironmentNotificationPlugin::WarningNotification",
    "EnvironmentNotificationPlugin::SuccessNotification",
    "EnvironmentNotificationPlugin::InformationNotification",
    "EnvironmentNotificationPlugin::DangerNotification"
  ]

  attr_accessible :message, :environment_id, :active, :type, :display_only_in_homepage, :display_to_all_users, :display_popup, :title

  has_many :environment_notifications_users
  has_many :users, :through => :environment_notifications_users

  validates_presence_of :message
  validates_presence_of :environment_id
  validate :notification_type_must_be_in_type_list

  def notification_type_must_be_in_type_list
    unless TYPE_LIST.include?(type)
      errors.add(:type, "invalid notification type")
    end
  end

  scope :active, lambda{|environment| { :conditions => { :environment_id => environment.id, :active => true } } }

  def self.visibles(environment, user, controller_path)
    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.active(environment).order('updated_at DESC')

    if user
      active_notifications_ids = notifications.pluck(:id) - user.environment_notifications.pluck(:id)

      notifications = notifications.where(id: active_notifications_ids)
    else
      notifications = notifications.where(display_to_all_users: true)
    end

    if controller_path != "home"
      notifications = notifications.where(display_only_in_homepage: false)
    end

    notifications
  end

  def self.with_popup(environment, user, previous_path)
    notifications = EnvironmentNotificationPlugin::EnvironmentNotification.visibles(environment, user, previous_path).where(display_popup: true)
  end
end
