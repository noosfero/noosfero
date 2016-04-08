class SetProductCategoryIdToProducts < ActiveRecord::Migration
  def self.up
    Product.where(product_category_id: nil).find_each do |product|
      next if product.enterprise.nil?
      product.update_attribute(:product_category_id, ProductCategory.top_level_for(product.enterprise.environment).first.id)
    end
  end

  def self.down
    say "WARNING: cannot undo this migration"
  end
end
