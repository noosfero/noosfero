class AddTimestampsInProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :created_at, :datetime
    add_column :products, :updated_at, :datetime
  end

  def self.down
    remove_column :products, :created_at, :datetime
    remove_column :products, :updated_at, :datetime
  end
end
