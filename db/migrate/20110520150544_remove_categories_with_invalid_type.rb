class RemoveCategoriesWithInvalidType < ActiveRecord::Migration

  def self.remove_invalid(category)
    if category.class != ProductCategory && !category.class.ancestors.include?(ProductCategory)
      category.destroy
    else
      category.children.map { |child| remove_invalid(child) }
    end
  end

  def self.up
    ProductCategory.all.map { |category| remove_invalid(category)}
  end

  def self.down
    say "this migration can't be reverted"
  end
end
