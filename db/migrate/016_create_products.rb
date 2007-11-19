class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.column :enterprise_id,        :integer
      t.column :product_category_id,  :integer
      t.column :name,                 :string
      t.column :price,                :decimal
    end
  end

  def self.down
    drop_table :products
  end
end
