class CreateSuppliersPluginTables < ActiveRecord::Migration
  def self.up
    # check if distribution plugin already moved the table
    return if ApplicationRecord.connection.table_exists? :suppliers_plugin_suppliers

    create_table :suppliers_plugin_suppliers do |t|
      t.integer  :profile_id
      t.integer  :consumer_id
      t.string   :name
      t.string   :name_abbreviation
      t.text     :description
      t.timestamps
    end

    add_index :suppliers_plugin_suppliers, [:consumer_id]
  end

  def self.down
    drop_table :suppliers_plugin_suppliers
  end
end
