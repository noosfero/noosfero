class AddColumnsToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :unit, :string
    add_column :products, :discount, :float
    add_column :products, :available, :boolean
  end

  def self.down
    remove_column :products, :unit
    remove_column :products, :discount
    remove_column :products, :available
  end
end
