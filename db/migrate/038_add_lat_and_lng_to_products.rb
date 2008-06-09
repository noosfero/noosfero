class AddLatAndLngToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :lat, :float
    add_column :products, :lng, :float
  end

  def self.down
    remove_column :products, :lat
    remove_column :products, :lng
  end
end
