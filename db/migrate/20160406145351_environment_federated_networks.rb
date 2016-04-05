class EnvironmentFederatedNetworks < ActiveRecord::Migration
  def self.up
    create_table :environment_federated_networks do |t|
      t.references :environment, index: true
      t.references :federated_network, index: true
    end
  end

  def self.down
    drop_table :environment_federated_networks
  end
end
