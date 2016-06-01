class EnvironmentExternalEnvironment < ActiveRecord::Base
  belongs_to :environment
  belongs_to :external_environment

  attr_accessible :environment, :external_environment

  validates_uniqueness_of :external_environment, :scope => :environment
end
