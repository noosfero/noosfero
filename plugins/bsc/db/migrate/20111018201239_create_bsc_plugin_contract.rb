class CreateBscPluginContract < ActiveRecord::Migration
  def self.up
    create_table :bsc_plugin_contracts do |t|
      t.string      :client_name
      t.integer     :client_type
      t.integer     :business_type
      t.string      :state
      t.string      :city
      t.integer     :status, :default => 0
      t.integer     :number_of_producers, :default => 0
      t.datetime    :supply_start
      t.datetime    :supply_end
      t.text        :annotations
      t.references  :bsc
      t.timestamps
    end
  end

  def self.down
    drop_table :bsc_plugin_contracts
  end
end
