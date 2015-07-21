module EnvironmentNotificationHelper
  def self.substitute_variables(message, user)
    if user
      message = message.gsub("%{email}", user.person.email).gsub("%{name}", user.person.name)
    end

    message
  end
end