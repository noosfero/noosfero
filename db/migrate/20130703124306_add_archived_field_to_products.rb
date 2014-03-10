class AddArchivedFieldToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :archived, :boolean, :default => false
  end

  def self.down
    remove_column :products, :archived
  end
end
