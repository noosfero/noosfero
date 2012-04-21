class CreateBscPluginContractsEnterprises < ActiveRecord::Migration
  def self.up
    create_table :bsc_plugin_contracts_enterprises, :id => false do |t|
      t.references :contract
      t.references :enterprise
    end
  end

  def self.down
    drop_table :bsc_plugin_contracts_enterprises
  end
end
