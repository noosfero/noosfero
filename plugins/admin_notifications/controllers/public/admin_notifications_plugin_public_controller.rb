class AdminNotificationsPluginPublicController < PublicController

  helper AdminNotificationsPlugin::NotificationHelper
  include AdminNotificationsPlugin::NotificationHelper

  def notifications_with_popup
    @hide_notifications = hide_notifications
    if params[:previous_path]
      @previous_path = params[:previous_path]
    else
      @previous_path = nil
    end
  end

  def close_notification
    result = false

    if logged_in?
      @notification = AdminNotificationsPlugin::Notification.find_by_id(params[:notification_id])

      if @notification
        @notification.users << current_user
        result = @notification.users.include?(current_user)
      end
    end

    render json: result
  end

  def hide_notification
    result = false

    if logged_in?
      @notification = AdminNotificationsPlugin::Notification.find_by_id(params[:notification_id])

      if @notification
        current_notificaions = []
        current_notificaions = JSON.parse(cookies[:hide_notifications]) unless cookies[:hide_notifications].blank?
        current_notificaions << @notification.id unless current_notificaions.include? @notification.id
        cookies[:hide_notifications] = JSON.generate(current_notificaions)
        result = current_notificaions.include? @notification.id
      end
    end

    render json: result
  end

end
