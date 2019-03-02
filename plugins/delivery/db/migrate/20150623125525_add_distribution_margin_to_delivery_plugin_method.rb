class AddDistributionMarginToDeliveryPluginMethod < ActiveRecord::Migration[5.1]

  def change
    add_column :delivery_plugin_methods, :distribution_margin_fixed, :decimal
    add_column :delivery_plugin_methods, :distribution_margin_percentage, :decimal
  end

end
