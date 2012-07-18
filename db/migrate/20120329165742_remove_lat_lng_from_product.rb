class RemoveLatLngFromProduct < ActiveRecord::Migration
  def self.up
    remove_column :products, :lat
    remove_column :products, :lng
  end

  def self.down
    say "this migration can't be reverted"
  end
end
