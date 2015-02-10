class AddAncestryToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :ancestry, :text

    Category.build_ancestry
  end

  def self.down
    remove_column :categories, :ancestry
  end
end
