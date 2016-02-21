class CreateProductCategorizations < ActiveRecord::Migration
  def self.up

    create_table :product_categorizations do |t|
      t.integer :category_id
      t.integer :product_id
      t.boolean :virtual, :default => false

      t.timestamps
    end

    total = Product.count.to_f
    percent = 0
    Product.find_each_with_index do |p,i|
      if p.product_category
        ProductCategorization.add_category_to_product(p.product_category, p)
      end
      puts "%02.02f" % ((100.0 * i.to_f)/total)
    end

  end

  def self.down
    drop_table :product_categorizations
  end
end
