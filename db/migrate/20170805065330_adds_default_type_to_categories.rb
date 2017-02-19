class AddsDefaultTypeToCategories < ActiveRecord::Migration
  def up
    change_column :categories, :type, :string, :default => "Category"
    Category.where("type is null").update_all(type: "Category")
  end

  def down
    change_column :categories, :type, :string, :default => nil
    Category.where("type='Category'").update_all(type: nil)
  end
end
