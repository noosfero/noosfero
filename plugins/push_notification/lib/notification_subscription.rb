class PushNotificationPlugin::NotificationSubscription < ApplicationRecord
  belongs_to :environment, optional: true
  attr_accessible :subscribers, :notification, :environment

  validates :notification, uniqueness: true
  serialize :subscribers
end
