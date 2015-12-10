require_relative "../lib/notification_settings"
require_relative "../lib/device_token"

class PushNotificationPluginMyprofileController < MyProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index
    @devices = current_user.device_tokens
    @settings = filter_notifications current_user.notification_settings.hash_flags
  end

  def delete_device
    device = PushNotificationPlugin::DeviceToken.find(params["device"])
    device.delete
    redirect_to :action => "index"
  end

  def update_settings
    current_user.notification_settings.set_notifications(params["settings"] || {})
    current_user.save
    redirect_to :action => "index"
  end

  private

  def filter_notifications hash_flags
    server_settings = Noosfero::Plugin::Settings.new(environment, PushNotificationPlugin)
    server_notifications = server_settings.notifications || {}
    filtered_settings = {}
    hash_flags.each do |notification, enabled|
      filtered_settings[notification] = enabled if server_notifications[notification] == "1"
    end
    filtered_settings
  end
end
