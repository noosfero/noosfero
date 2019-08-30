class OauthClientPlugin::Provider < ApplicationRecord
  belongs_to :environment, optional: true

  validates_presence_of :name, :strategy

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
end
