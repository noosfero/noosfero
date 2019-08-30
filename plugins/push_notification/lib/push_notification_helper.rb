module PushNotificationHelper
  def fcm_instance
    api_key = plugin_settings.settings[:server_api_key]
    fcm = FCM.new(api_key)
    fcm
  end

  def plugin_settings
    return Noosfero::Plugin::Settings.new(environment, PushNotificationPlugin)
  end

  # data should be a hash inside `data` attribute, like {some_info: 123123}
  def send_to_users(flag, users, data)
    return false unless users.present?

    users |= subscribers_additional_users(flag, users.first.environment)
    users = filter_users_for_flag(flag, users)
    return false unless users.present?

    tokens = tokens_for_users(users)
    fcm = fcm_instance
    response = fcm.send(tokens, data: data)
    response[:response]
  end

  def filter_users_for_flag(flag, users)
    users.select { |u| u.notification_settings.active?(flag) }
  end

  def tokens_for_users(users)
    tokens = []
    users.each { |c| tokens += c.device_token_list }
    return tokens
  end

  def subscribers_additional_users(notification, environment)
    subs = PushNotificationPlugin::subscribers(environment, notification)
    users = []
    if subs.present?
      subs.each do |s|
        users += s.send("push_notification_#{notification}_additional_users".to_sym)
      end
    end
    users
  end
end
