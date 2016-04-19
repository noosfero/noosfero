class EnvironmentFederatedNetwork < ActiveRecord::Base
  belongs_to :environment
  belongs_to :federated_network

  attr_accessible :environment, :federated_network

  validates_uniqueness_of :federated_network, :scope => :environment
end
