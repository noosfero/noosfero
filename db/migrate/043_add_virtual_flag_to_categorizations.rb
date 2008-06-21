class AddVirtualFlagToCategorizations < ActiveRecord::Migration
  def self.up
    add_column :articles_categories, :virtual, :boolean, :default => false
    add_column :categories_profiles, :virtual, :boolean, :default => false
  end

  def self.down
    remove_column :articles_categories, :virtual
    remove_column :categories_profiles, :virtual
  end
end
