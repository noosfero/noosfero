class ExternalEnvironment < ActiveRecord::Base
  validates_presence_of :url, :name, :identifier
  validates_uniqueness_of :url, :name, :identifier

  attr_accessible :name, :url, :thumbnail, :screenshot, :identifier

  has_many :environment_external_environments, dependent: :destroy
  has_many :environments, through: :environment_external_environments
end
