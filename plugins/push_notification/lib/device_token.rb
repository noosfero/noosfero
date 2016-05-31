class PushNotificationPlugin::DeviceToken < ApplicationRecord
  belongs_to :user
  attr_accessible :token, :device_name, :user

  after_save :check_notification_settings

  private

  def check_notification_settings
    if user.notification_settings.nil?
      user.notification_settings=PushNotificationPlugin::NotificationSettings.new
      user.save
    end
  end

end
