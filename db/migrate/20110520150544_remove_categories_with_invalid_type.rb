class RemoveCategoriesWithInvalidType < ActiveRecord::Migration

  def self.remove_invalid(category)
    if category.class != ProductCategory && !category.class.ancestors.include?(ProductCategory)
      execute("update categories set type='ProductCategory' where id=#{category.id}")
    else
      category.children.map { |child| remove_invalid(child) }
    end
  end

  def self.up
    select_all("SELECT id from categories WHERE type = 'ProductCategory'").each do |product_category|
      category = ProductCategory.find(product_category['id'])
      remove_invalid(category)
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
