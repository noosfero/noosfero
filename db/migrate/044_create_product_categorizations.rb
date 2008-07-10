class CreateProductCategorizations < ActiveRecord::Migration
  def self.up
    
    create_table :product_categorizations do |t|
      t.integer :category_id
      t.integer :product_id
      t.boolean :virtual, :default => false

      t.timestamps
    end

# FIXME:uncomment after implementation
#    Product.find(:all).each do |p|
#      ProductCategorization.add_category_to_product(p.product_category, p)
#    end

  end

  def self.down
    drop_table :product_categorizations
  end
end
