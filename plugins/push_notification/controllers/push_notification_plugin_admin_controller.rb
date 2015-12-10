require_relative "../lib/notification_settings"

class PushNotificationPluginAdminController < PluginAdminController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index
    @server_settings = Noosfero::Plugin::Settings.new(environment, PushNotificationPlugin)
    @settings = @server_settings.notifications || PushNotificationPlugin::NotificationSettings.default_hash_flags
  end

  def update
    data = params[:server_settings]
    data[:notifications] = params[:settings]
    @server_settings = Noosfero::Plugin::Settings.new(environment, PushNotificationPlugin, data)
    @server_settings.save!
    redirect_to :action => "index"
  end

end
