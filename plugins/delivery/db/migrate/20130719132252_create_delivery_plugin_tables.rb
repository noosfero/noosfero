class CreateDeliveryPluginTables < ActiveRecord::Migration
  def self.up
    # check if distribution plugin already moved tables
    return if ApplicationRecord.connection.table_exists? :delivery_plugin_methods

    create_table :delivery_plugin_methods do |t|
      t.integer  :profile_id
      t.string   :name
      t.text     :description
      t.string   :recipient
      t.string   :address_line1
      t.string   :address_line2
      t.string   :postal_code
      t.string   :state
      t.string   :country
      t.string   :delivery_type
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :delivery_plugin_methods, [:profile_id]
    add_index :delivery_plugin_methods, [:delivery_type]

    create_table :delivery_plugin_options do |t|
      t.integer  :delivery_method_id
      t.integer  :owner_id
      t.string   :owner_type
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :delivery_plugin_options, [:delivery_method_id]
    add_index :delivery_plugin_options, [:owner_id, :delivery_method_id], name: :index_delivery_plugin_owner_id_delivery_method_id
    add_index :delivery_plugin_options, [:owner_id]
    add_index :delivery_plugin_options, [:owner_type]
    add_index :delivery_plugin_options, [:owner_id, :owner_type]

  end

  def self.down
    drop_table :delivery_plugin_methods
    drop_table :delivery_plugin_options
  end
end
