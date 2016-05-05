class AdminNotificationsPlugin::Notification < ActiveRecord::Base

  self.table_name = "admin_notifications_plugin_notifications"

  TYPE_LIST = [
    "AdminNotificationsPlugin::WarningNotification",
    "AdminNotificationsPlugin::SuccessNotification",
    "AdminNotificationsPlugin::InformationNotification",
    "AdminNotificationsPlugin::DangerNotification"
  ]

  attr_accessible :message, :target_id, :active, :type, :display_only_in_homepage, :display_to_all_users, :display_popup, :title, :target

  has_many :notifications_users, :class_name => "AdminNotificationsPlugin::NotificationsUser"
  has_many :users, :through => :notifications_users

  belongs_to :target, :polymorphic => true

  validates_presence_of :message
  validates_presence_of :target_id
  validate :notification_type_must_be_in_type_list

  def notification_type_must_be_in_type_list
    unless TYPE_LIST.include?(type)
      errors.add(:type, "invalid notification type")
    end
  end

  scope :active, lambda{|target| where(:target_id => (target.kind_of?(Organization) ? [target.id, target.environment.id] : target.id), :active => true)}

  def self.visibles(target, user, controller_path)
    notifications = AdminNotificationsPlugin::Notification.active(target).order('updated_at DESC')

    if user
      active_notifications_ids = notifications.pluck(:id) - user.notifications.pluck(:id)

      notifications = notifications.where(id: active_notifications_ids)
    else
      notifications = notifications.where(display_to_all_users: true)
    end

    if controller_path != "home"
      notifications = notifications.where.not("display_only_in_homepage = ? AND target_type = ?",true,"Environment")
      if controller_path != "profile"
        notifications = notifications.where.not("display_only_in_homepage = ? AND target_type = ?",true,"Profile")
      end
    end

    notifications
  end

  def self.with_popup(target, user, previous_path)
    AdminNotificationsPlugin::Notification.visibles(target, user, previous_path).where(display_popup: true)
  end

end
