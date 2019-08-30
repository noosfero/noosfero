require_relative "api_entities"

# Can't be called Api as will result in:
# warning: toplevel constant Api referenced by PushNotificationPlugin::Api
# To fix this PushNotificationPlugin should be a module
class PushNotificationPlugin::API < Grape::API::Instance
  include Api::Helpers

  resource :push_notification_plugin do
    helpers do
      def target
        if params.has_key?(:target_id)
          target_user = environment.users.detect { |u| u.id == params[:target_id].to_i }
        else
          target_user = current_user
        end

        if !current_person.is_admin? && (target_user.nil? || target_user != current_user)
          render_api_error!(_("Unauthorized"), 401)
        end

        return target_user
      end
    end

    get "device_tokens" do
      authenticate!
      target_user = target
      tokens = target_user.device_token_list || []
      present tokens
    end

    post "device_tokens" do
      authenticate!
      target_user = target

      bad_request!("device_name") unless params[:device_name]
      token = PushNotificationPlugin::DeviceToken.new(device_name: params[:device_name], token: params[:token], user: target_user) if !target_user.device_token_list.include?(params[:token])

      target_user.device_tokens.push(token)

      unless target_user.save
        render_model_errors!(target_user.errors)
      end
      present target_user, with: PushNotificationPlugin::Entities::DeviceUser
    end

    delete "device_tokens" do
      authenticate!
      target_user = target

      PushNotificationPlugin::DeviceToken.where("token = ? AND user_id = (?)", params[:token], target_user.id)
                                         .delete_all

      present target_user, with: PushNotificationPlugin::Entities::DeviceUser
    end

    get "notification_settings" do
      authenticate!
      target_user = target

      present target_user, with: PushNotificationPlugin::Entities::DeviceUser
    end

    get "possible_notifications" do
      result = { possible_notifications: PushNotificationPlugin::NotificationSettings::NOTIFICATIONS.keys }
      present result, with: Grape::Presenters::Presenter
    end

    post "notification_settings" do
      authenticate!
      target_user = target

      PushNotificationPlugin::NotificationSettings::NOTIFICATIONS.keys.each do |notification|
        next unless params.keys.include?(notification)

        state = params[notification]
        target_user.notification_settings.set_notification_state notification, state
      end

      target_user.save!
      present target_user, with: PushNotificationPlugin::Entities::DeviceUser
    end

    get "active_notifications" do
      authenticate!
      target_user = target
      present target_user.notification_settings.active_notifications, with: Grape::Presenters::Presenter
    end

    get "inactive_notifications" do
      authenticate!
      target_user = target
      present target_user.notification_settings.inactive_notifications, with: Grape::Presenters::Presenter
    end
  end
end
