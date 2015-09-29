module EnvironmentNotificationHelper

  def hide_notifications
    invalid_id = -1
    hide_notifications_ids = [invalid_id]
    hide_notifications_ids = JSON.parse(cookies[:hide_notifications]) unless cookies[:hide_notifications].blank?
    hide_notifications_ids
  end

  def self.substitute_variables(message, user)
    if user
      message = message.gsub("%{email}", user.person.email).gsub("%{name}", user.person.name)
    end

    message
  end

end
