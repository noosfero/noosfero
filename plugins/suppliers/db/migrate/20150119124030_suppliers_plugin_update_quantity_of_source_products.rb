class SuppliersPluginUpdateQuantityOfSourceProducts < ActiveRecord::Migration
  def up
    change_column_default :suppliers_plugin_source_products, :quantity, 1.0
    SuppliersPlugin::SourceProduct.update_all quantity: 1.0
  end

  def down
    change_column_default :suppliers_plugin_source_products, :quantity, 0
    SuppliersPlugin::SourceProduct.update_all quantity: 0
  end
end
