class AddTypeToOrdersPluginItem < ActiveRecord::Migration
  def up
    add_column :orders_plugin_items, :type, :string
  end

  def down
    remove_column :orders_plugin_items, :type, :string
  end
end
