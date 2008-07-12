class AggressiveIndexingStrategy1 < ActiveRecord::Migration
  def self.up
    # profile categorizations
    add_index(:categories_profiles, :profile_id)
    add_index(:categories_profiles, :category_id)

    # product categorizations
    add_index(:product_categorizations, :product_id)
    add_index(:product_categorizations, :category_id)

    # finding products by the enterprises that own them
    add_index(:products, :enterprise_id)

    # finding profiles by their environment
    add_index(:profiles, :environment_id)

    # finding blocks by their box, and boxes by their owner
    add_index(:blocks, :box_id)
    add_index(:boxes, [:owner_type, :owner_id])
  end

  def self.down
    remove_index(:categories_profiles, :column => :profile_id)
    remove_index(:categories_profiles, :column => :category_id)
    remove_index(:product_categorizations, :column => :product_id)
    remove_index(:product_categorizations, :column => :category_id)
    remove_index(:products, :column => :enterprise_id)
    remove_index(:profiles, :column => :environment_id)
    remove_index(:blocks, :column => :box_id)
    remove_index(:boxes, :column => [:owner_type, :owner_id])
  end
end
