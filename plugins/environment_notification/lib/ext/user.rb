require_dependency 'user'

class User
  has_many :environment_notifications_users
  has_many :environment_notifications, :through => :environment_notifications_users
end
