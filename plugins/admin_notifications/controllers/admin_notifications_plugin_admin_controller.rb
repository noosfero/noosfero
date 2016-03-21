class AdminNotificationsPluginAdminController < AdminController

  include AdminNotificationsPlugin::NotificationManager

  before_filter :admin_required

  protected
  def target
    environment
  end

  def admin_required
    redirect_to :root unless current_person.is_admin?
  end

end
