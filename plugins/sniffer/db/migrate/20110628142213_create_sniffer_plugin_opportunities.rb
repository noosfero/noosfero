class CreateSnifferPluginOpportunities < ActiveRecord::Migration
  def self.up
    create_table :sniffer_plugin_opportunities do |t|
      t.integer :profile_id
      t.integer :opportunity_id
      t.string :opportunity_type

      t.timestamps
    end
  end

  def self.down
    drop_table :sniffer_plugin_opportunities
  end
end
