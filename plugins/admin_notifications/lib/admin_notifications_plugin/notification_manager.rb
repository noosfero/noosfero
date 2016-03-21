module AdminNotificationsPlugin::NotificationManager

  def index
    @notifications = target.notifications.order('updated_at DESC')
  end

  def new
    @notification = AdminNotificationsPlugin::Notification.new
    if request.post?
      @notification = AdminNotificationsPlugin::Notification.new(params[:notifications])
      @notification.message = @notification.message.html_safe
      @notification.target = target
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
      notification = target.notifications.find_by id: params[:id]
      if notification && notification.destroy
        session[:notice] = _('The notification was deleted.')
      else
        session[:notice] = _('Could not remove the notification')
      end
    end
    redirect_to :action => :index
  end

  def edit
    @notification = target.notifications.find_by id: params[:id]
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
    @notification = target.notifications.find_by id: params[:id]

    @notification.active = !@notification.active

    if @notification.save!
      session[:notice] = _('The status of the notification was changed.')
    else
      session[:notice] = _('Could not change the status of the notification.')
    end

    redirect_to :action => :index
  end

end
