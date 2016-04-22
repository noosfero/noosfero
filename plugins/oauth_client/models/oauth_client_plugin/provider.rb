class OauthClientPlugin::Provider < ApplicationRecord

  belongs_to :environment

  validates_presence_of :name, :strategy

  acts_as_having_image
  acts_as_having_settings field: :options

  settings_items :site, type: String
  settings_items :client_options, type: Hash

  attr_accessible :name, :strategy, :enabled, :site, :image_builder,
    :environment, :environment_id, :options,
    :client_id, :client_secret, :client_options

  scope :enabled, -> { where enabled: true }

  acts_as_having_image

end
