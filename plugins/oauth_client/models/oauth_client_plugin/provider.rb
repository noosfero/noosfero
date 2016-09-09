class OauthClientPlugin::Provider < ApplicationRecord

  belongs_to :environment

  validates_presence_of :name, :strategy

  validate :noosfero_provider_must_have_a_site

  extend ActsAsHavingImage::ClassMethods
  acts_as_having_image

  extend ActsAsHavingSettings::ClassMethods
  acts_as_having_settings field: :options

  settings_items :site, type: String
  settings_items :client_options, type: Hash

  attr_accessible :name, :strategy, :enabled, :site, :image_builder,
    :environment, :environment_id, :options,
    :client_id, :client_secret, :client_options

  scope :enabled, -> { where enabled: true }

  def noosfero_provider_must_have_a_site
    if self.strategy == 'noosfero_oauth2' && (self.client_options.nil? || self.client_options[:site].blank?)
      self.errors.add(:site, "A Noosfero provider must have a site")
    end
  end
end
