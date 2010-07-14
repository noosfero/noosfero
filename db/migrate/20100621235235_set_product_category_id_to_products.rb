class SetProductCategoryIdToProducts < ActiveRecord::Migration
  def self.up
    Product.all(:conditions => { :product_category_id => nil }).each do |product|
      next if product.enterprise.nil?
      product.product_category = ProductCategory.top_level_for(product.enterprise.environment).first
      product.save!
    end
  end

  def self.down
    say "WARNING: cannot undo this migration"
  end
end
