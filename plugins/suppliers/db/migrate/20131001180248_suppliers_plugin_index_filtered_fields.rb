class SuppliersPluginIndexFilteredFields < ActiveRecord::Migration
  def self.up
    add_index :suppliers_plugin_suppliers, [:profile_id]
    add_index :suppliers_plugin_suppliers, [:profile_id, :consumer_id]

    add_index :suppliers_plugin_source_products, [:from_product_id, :to_product_id], :name => 'suppliers_plugin_index_dtBULzU3'
    add_index :suppliers_plugin_source_products, [:supplier_id], :name => 'suppliers_plugin_index_Lm5QPpV8'
    add_index :suppliers_plugin_source_products, [:supplier_id, :from_product_id], :name => 'suppliers_plugin_index_naHsVLS6cH'
    add_index :suppliers_plugin_source_products, [:supplier_id, :to_product_id], :name => 'suppliers_plugin_index_LgsgYqCQI'
    add_index :suppliers_plugin_source_products, [:supplier_id, :from_product_id, :to_product_id], :name => 'suppliers_plugin_index_VBNqyeCP'
  end

  def self.down
    say "this migration can't be reverted"
  end
end
