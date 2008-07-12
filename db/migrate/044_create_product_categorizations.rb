class CreateProductCategorizations < ActiveRecord::Migration
  def self.up
    
    create_table :product_categorizations do |t|
      t.integer :category_id
      t.integer :product_id
      t.boolean :virtual, :default => false

      t.timestamps
    end

    Product.find(:all).each do |p|
      if p.product_category
        ProductCategorization.add_category_to_product(p.product_category, p)
        print ".\0"
      else
        print "x\0"
      end
      $stdout.flush
    end
    print "\n"

  end

  def self.down
    drop_table :product_categorizations
  end
end
