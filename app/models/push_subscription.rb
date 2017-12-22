class PushSubscription < ApplicationRecord

  validates_presence_of :endpoint, :keys, :owner
  validate :contains_keys

  belongs_to :environment
  belongs_to :owner, polymorphic: true

  before_save :add_owner_environment

  def subject
    environment.contact_email.present? ? "mailto:#{environment.contact_email}"
                                       : environment.top_url
  end

  private

  def contains_keys
    if keys['p256dh'].blank? || keys['auth'].blank?
      errors.add(:keys, 'must contain p256dh and auth keys')
    end
  end

  def add_owner_environment
    self.environment = owner.environment
  end

end
