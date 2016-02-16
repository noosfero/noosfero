class AddStatusToOrdersPluginItem < ActiveRecord::Migration

  def change
    add_column :orders_plugin_items, :status, :string
    add_column :orders_plugin_orders, :building_next_status, :boolean

    say_with_time "filling items' statuses..." do
      OrdersPlugin::Item.includes(:order).find_each batch_size: 50 do |item|
        next item.destroy if item.order.nil?
        item.fill_status
      end
    end
  end

end
