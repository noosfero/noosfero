require_dependency 'environment'

class Environment
  has_many :environment_notifications, class_name: 'EnvironmentNotificationPlugin::EnvironmentNotification'
end
