class OrdersCyclePluginIndexFilteredFields < ActiveRecord::Migration

  def up
    add_index :orders_cycle_plugin_cycle_orders, [:cycle_id]
    add_index :orders_cycle_plugin_cycle_orders, [:order_id]
    add_index :orders_cycle_plugin_cycle_orders, [:cycle_id, :order_id]

    add_index :orders_cycle_plugin_cycle_products, [:cycle_id], name: :orders_cycle_plugin_index_dqaEe7Hf
    add_index :orders_cycle_plugin_cycle_products, [:product_id], name: :orders_cycle_plugin_index_f5DmQ6w5Y
    add_index :orders_cycle_plugin_cycle_products, [:cycle_id, :product_id], name: :orders_cycle_plugin_index_PhBVTRFB

    add_index :orders_cycle_plugin_cycles, [:code]
  end

  def down
    say "this migration can't be reverted"
  end

end
