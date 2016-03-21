class ChangeTypeToNewNamespace < ActiveRecord::Migration
  def up
    notification_types = %w(InformationNotification DangerNotification SuccessNotification WarningNotification)
    notification_types.each do |notification_type|
      execute("update admin_notifications_plugin_notifications set type = 'AdminNotificationsPlugin::#{notification_type}' where type = 'EnvironmentNotificationPlugin::#{notification_type}'")
    end
  end
end
