class EnvironmentNotificationPluginPublicController < PublicController

  helper EnvironmentNotificationHelper
  include EnvironmentNotificationHelper

  def notifications_with_popup
    @hide_notifications = hide_notifications
    if params[:previous_path]
      @previous_path = params[:previous_path]
    else
      @previous_path = nil
    end
  end

end
