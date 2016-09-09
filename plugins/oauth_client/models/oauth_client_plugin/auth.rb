class OauthClientPlugin::Auth < ApplicationRecord

  attr_accessible :profile, :provider, :provider_id, :enabled,
                  :access_token, :expires_in, :type, :external_person_uid,
                  :external_person_image_url

  belongs_to :profile, polymorphic: true
  belongs_to :provider, class_name: 'OauthClientPlugin::Provider'

  validates_presence_of :provider
  validates_presence_of :profile
  validates_uniqueness_of :profile_id, scope: :provider_id

  extend ActsAsHavingSettings::ClassMethods
  acts_as_having_settings field: :data

  def expires_in
    self.expires_at - Time.now
  end
  def expires_in= value
    self.expires_at = Time.now + value.to_i
  end

  def expired?
    Time.now > self.expires_at rescue true
  end
  def not_expired?
    not self.expired?
  end

  def allow_login?
    self.enabled? && self.provider.enabled?
  end

  def self.create_for_strategy(strategy, args = {})
    namespace = self.name.split("::")[0]
    class_name = "#{namespace}::#{strategy.camelize}Auth"
    OauthClientPlugin::Auth.create!(args.merge(type: class_name))
  end

  IMAGE_SIZES = {
                 :big => "150",
                 :thumb => "100",
                 :portrait => "64",
                 :minor => "50",
                 :icon => "18"
                }

  # The following methods should be implemented by
  # the Provider specific Auth classes
  def image_url(size = nil)
    nil
  end
  def profile_url
    nil
  end
  def settings_url
    nil
  end

end
