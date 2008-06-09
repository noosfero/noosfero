class AddDisplayInMenuToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :display_in_menu, :boolean, :default => false
  end

  def self.down
    remove_column :categories, :display_in_menu
  end
end
