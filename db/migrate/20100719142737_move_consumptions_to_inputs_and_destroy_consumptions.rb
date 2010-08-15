class MoveConsumptionsToInputsAndDestroyConsumptions < ActiveRecord::Migration
  def self.up
    select_all('SELECT product_category_id, profile_id FROM consumptions').each do |consumption|
      enterprise = Enterprise.exists?(consumption['profile_id']) ? Enterprise.find(consumption['profile_id']) : nil
      if enterprise
        enterprise.products.each do |product|
          category_id = consumption['product_category_id']
          category_id ||= ProductCategory.first.id
          execute("INSERT INTO inputs (product_category_id, product_id) VALUES(#{category_id}, #{product.id})")
        end
      end
    end
    drop_table :consumptions
  end

  def self.down
    say 'Warning: This migration cant recover data from old cunsumptions table'
    create_table :consumptions do |t|
      t.column :product_category_id,     :integer
      t.column :profile_id,              :integer
      t.column :aditional_specifications, :text
    end
  end
end
