module PushNotificationPlugin::Entities
  class DeviceUser < Noosfero::API::Entities::User
    expose :device_token_list, :as => :device_tokens
    expose :notification_settings do |user, options|
      user.notification_settings.hash_flags
    end
  end

end
