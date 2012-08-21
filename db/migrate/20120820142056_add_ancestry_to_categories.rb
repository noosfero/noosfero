class AddAncestryToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :ancestry, :text

    Category.all.each do |category|
      category.set_ancestry
      category.save!
    end
  end

  def self.down
    remove_column :categories, :ancestry
  end
end
