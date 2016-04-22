class SuppliersPlugin::Supplier < ApplicationRecord
end

class AddActiveToSuppliersPluginSupplier < ActiveRecord::Migration
  def self.up
    add_column :suppliers_plugin_suppliers, :active, :boolean, default: true
    SuppliersPlugin::Supplier.update_all active: true
  end

  def self.down
    remove_column :suppliers_plugin_suppliers, :active
  end
end
