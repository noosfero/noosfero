class EnvironmentNotificationPluginAdminController < AdminController

  helper EnvironmentNotificationHelper
  include EnvironmentNotificationHelper

  before_filter :admin_required, :except => [:close_notification, :hide_notification]

  def index
    @notifications = environment.environment_notifications.order('updated_at DESC')
  end

  def new
    @notification = EnvironmentNotificationPlugin::EnvironmentNotification.new
    if request.post?
      @notification = EnvironmentNotificationPlugin::EnvironmentNotification.new(params[:notifications])
      @notification.message = @notification.message.html_safe
      @notification.environment_id = environment.id
      if @notification.save
        session[:notice] = _("Notification successfully created")
        redirect_to :action => :index
      else
        session[:notice] = _("Notification couldn't be created")
      end
    end
  end

  def destroy
    if request.delete?
      notification = environment.environment_notifications.find_by id: params[:id]
      if notification && notification.destroy
        session[:notice] = _('The notification was deleted.')
      else
        session[:notice] = _('Could not remove the notification')
      end
    end
    redirect_to :action => :index
  end

  def edit
    @notification = environment.environment_notifications.find_by id: params[:id]
    if request.post?
      if @notification.update_attributes(params[:notifications])
        session[:notice] = _('The notification was edited.')
      else
        session[:notice] = _('Could not edit the notification.')
      end
    redirect_to :action => :index
    end
  end

  def change_status
    @notification = environment.environment_notifications.find_by id: params[:id]

    @notification.active = !@notification.active

    if @notification.save!
      session[:notice] = _('The status of the notification was changed.')
    else
      session[:notice] = _('Could not change the status of the notification.')
    end

    redirect_to :action => :index
  end

  def close_notification
    result = false

    if logged_in?
      @notification = environment.environment_notifications.find_by id: params[:notification_id]

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
      @notification = environment.environment_notifications.find_by id: params[:notification_id]

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

  protected
  def admin_required
    redirect_to :root unless current_user.person.is_admin?
  end

end
