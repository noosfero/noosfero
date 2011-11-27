class RemoveUnusedColumnFromProducts < ActiveRecord::Migration
  def self.up
    remove_column :products, :image
  end

  def self.down
    add_column :products, :image, :string
  end
end
