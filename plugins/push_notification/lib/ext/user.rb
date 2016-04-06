require_dependency "user"
require_relative "../notification_subscription"
require_relative "../notification_settings"
require_relative "../device_token"

class User
  has_many :device_tokens, class_name: "PushNotificationPlugin::DeviceToken", :dependent => :destroy
  has_one :notification_settings, class_name: "PushNotificationPlugin::NotificationSettings",  :dependent => :destroy, :autosave => true

  after_save :save_notification_settings
  after_initialize :setup_notification_settings

  def device_token_list
    device_tokens.map { |t| t.token }
  end

  def enabled_notifications
    notification_settings.notifications
  end

  def enabled_notifications=(notifications)
    notification_settings.notifications=notifications
  end

  private

  def save_notification_settings
    notification_settings.save if notification_settings
  end

  def setup_notification_settings
    self.notification_settings = PushNotificationPlugin::NotificationSettings.new(:user => self) if self.notification_settings.nil?
  end

end
