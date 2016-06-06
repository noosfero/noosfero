class PushNotificationPlugin < Noosfero::Plugin

  include Noosfero::Plugin::HotSpot
  include PushNotificationPlugin::Observers

  def self.plugin_name
    I18n.t("push_notification_plugin.lib.plugin.name")
  end

  def self.subscribe environment, notification, klass
    return nil unless PushNotificationPlugin::NotificationSettings::NOTIFICATIONS.keys.include?(notification)
    return nil unless klass.name.constantize.respond_to?("push_notification_#{notification}_additional_users".to_sym)

    notification_subscription = PushNotificationPlugin::NotificationSubscription.where(:notification => notification).first
    notification_subscription ||= PushNotificationPlugin::NotificationSubscription.new({:notification => notification,
      :environment => environment, :subscribers => [klass.name]})

    notification_subscription.subscribers |= [klass.name]
    notification_subscription.save
  end

  def self.unsubscribe environment, notification, klass
    return nil unless PushNotificationPlugin::NotificationSettings::NOTIFICATIONS.keys.include?(notification)
    notification_subscription = PushNotificationPlugin::NotificationSubscription.where(:notification => notification, :environment => environment).first
    unless notification_subscription.blank?
      if notification_subscription.subscribers.include?(klass.name)
        notification_subscription.subscribers -= [klass.name]
        return notification_subscription.save
      end
    end
    return false
  end

  def self.subscribers environment, notification
    return nil unless PushNotificationPlugin::NotificationSettings::NOTIFICATIONS.keys.include?(notification)
    notification_subscription = PushNotificationPlugin::NotificationSubscription.where(:notification =>  notification, :environment => environment)
    return [] if notification_subscription.blank?
    notification_subscription.first.subscribers.map{|s| s.constantize}
  end

  def self.api_mount_points
    [PushNotificationPlugin::API]
  end

  def self.plugin_description
    I18n.t("push_notification_plugin.lib.plugin.description")
  end

  def stylesheet?
    true
  end

  def control_panel_buttons
    if context.profile.person?
      {
        title: I18n.t("push_notification_plugin.lib.plugin.panel_button"),
        icon: 'push-notifications',
        url: {controller: 'push_notification_plugin_myprofile', action: 'index'}
      }
    end
  end
end
