class AdminNotificationsPluginMyprofileController < MyProfileController

  include AdminNotificationsPlugin::NotificationManager

  before_filter :admin_required

  protected
  def target
    profile
  end

  def admin_required
    redirect_to :root unless target.is_admin?(current_person)
  end

end
