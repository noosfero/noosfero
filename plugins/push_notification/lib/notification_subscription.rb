class PushNotificationPlugin::NotificationSubscription < ActiveRecord::Base
  belongs_to :environment
  attr_accessible :subscribers, :notification, :environment

  validates :notification, :uniqueness => true
  serialize :subscribers

end

