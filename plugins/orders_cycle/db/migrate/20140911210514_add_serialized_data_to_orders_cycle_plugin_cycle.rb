class AddSerializedDataToOrdersCyclePluginCycle < ActiveRecord::Migration
  def self.up
    add_column :orders_cycle_plugin_cycles, :data, :text, :default => {}.to_yaml
    execute "update orders_cycle_plugin_cycles set data = '#{{}.to_yaml}'"
  end

  def self.down
    remove_column :orders_cycle_plugin_cycles, :data
  end
end
