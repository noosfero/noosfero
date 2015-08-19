class AddSessionIdToOrdersPluginOrders < ActiveRecord::Migration
  def change
    add_column :orders_plugin_orders, :session_id, :string
    add_index :orders_plugin_orders, :session_id
  end
end
