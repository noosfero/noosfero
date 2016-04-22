class PushNotificationPlugin::NotificationSettings < ApplicationRecord

  NOTIFICATIONS= {
    "add_friend" => 0x1,
    "new_comment" => 0x2,
    "add_member" => 0x4,
    "suggest_article" => 0x8,
    "new_article" => 0x10,
    "approve_article" => 0x20,
    "add_friend_result" => 0x40,
    "add_member_result" => 0x80,
    "approve_article_result" => 0x100,
    "suggest_article_result" => 0x200
  }

  belongs_to :user
  attr_accessible :user, :notifications

  def self.default_hash_flags
    default_hash_flags = {}
    NOTIFICATIONS.keys.each do |event|
      default_hash_flags[event] = "0"
    end
    default_hash_flags
  end

  def hash_flags
    flags = {}
    NOTIFICATIONS.keys.each do |notification|
      flags[notification] = active? notification
    end
    flags
  end

  def active_notifications
    NOTIFICATIONS.keys.select{|notification| active?(notification)}
  end

  def inactive_notifications
    NOTIFICATIONS.keys.select{|notification| !active?(notification)}
  end

  def active? notification
    ((self.notifications & NOTIFICATIONS[notification])!=0)
  end

  def activate_notification notification
    self.notifications |= NOTIFICATIONS[notification]
  end

  def set_notifications notifications
    NOTIFICATIONS.keys.each do |event|
      set_notification_state event, notifications[event]
    end
  end

  def deactivate_notification notification
    self.notifications &= ~NOTIFICATIONS[notification]
  end

  def set_notification_state notification, state
    if state.blank? || (state == 0) || (state == "0") || state == false
      deactivate_notification notification
    else
      activate_notification notification
    end
  end

end
