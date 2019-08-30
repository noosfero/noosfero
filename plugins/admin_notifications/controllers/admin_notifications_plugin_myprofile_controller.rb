class AdminNotificationsPluginMyprofileController < MyProfileController
  include AdminNotificationsPlugin::NotificationManager

  before_action :admin_required

  protected

    def target
      profile
    end

    def admin_required
      redirect_to :root unless (current_person.is_admin? || target.is_admin?(current_person))
    end
end
