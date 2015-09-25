require_dependency 'application_controller'

class ApplicationController
  def hide_notifications
    invalid_id = -1
    hide_notifications_ids = [-1]
    hide_notifications_ids = JSON.parse(cookies[:hide_notifications]) unless cookies[:hide_notifications].blank?
    hide_notifications_ids
  end
end
