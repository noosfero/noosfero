class AddIndexesForProductAndRelated < ActiveRecord::Migration
  def self.up
    # reduced from 75% to 5% postgres' cpu usage during solr indexing :)
    add_index :products, :product_category_id
    add_index :inputs, :product_category_id
    add_index :inputs, :product_id
    add_index :product_qualifiers, :product_id
    add_index :product_qualifiers, :qualifier_id
    add_index :product_qualifiers, :certifier_id
    add_index :profiles, :region_id
  end

  def self.down
    remove_index :products, :product_category_id
    remove_index :inputs, :product_category_id
    remove_index :inputs, :product_id
    remove_index :product_qualifiers, :product_id
    remove_index :product_qualifiers, :qualifier_id
    remove_index :product_qualifiers, :certifier_id
    remove_index :profiles, :region_id
  end
end
