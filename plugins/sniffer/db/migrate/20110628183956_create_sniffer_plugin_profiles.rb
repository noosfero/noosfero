class CreateSnifferPluginProfiles < ActiveRecord::Migration[5.1]
  def self.up
    create_table :sniffer_plugin_profiles do |t|
      t.integer :profile_id
      t.boolean :enabled

      t.timestamps
    end
  end

  def self.down
    drop_table :sniffer_plugin_profiles
  end
end
