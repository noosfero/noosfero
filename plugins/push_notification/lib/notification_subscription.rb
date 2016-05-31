class PushNotificationPlugin::NotificationSubscription < ApplicationRecord

  belongs_to :environment
  attr_accessible :subscribers, :notification, :environment

  validates :notification, :uniqueness => true
  serialize :subscribers

end

