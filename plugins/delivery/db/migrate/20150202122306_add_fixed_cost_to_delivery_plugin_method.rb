class AddFixedCostToDeliveryPluginMethod < ActiveRecord::Migration
  def up
    add_column :delivery_plugin_methods, :fixed_cost, :decimal
    add_column :delivery_plugin_methods, :free_over_price, :decimal
  end
  def down
    remove_column :delivery_plugin_methods, :fixed_cost
    remove_column :delivery_plugin_methods, :free_over_price
  end
end
