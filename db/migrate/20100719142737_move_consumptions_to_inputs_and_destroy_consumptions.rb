class MoveConsumptionsToInputsAndDestroyConsumptions < ActiveRecord::Migration
  def self.up
    select_all('SELECT product_category_id, profile_id FROM consumptions').each do |consumption|
      Profile.find(consumption['profile_id']).products.each do |product|
        Input.create(:product_category_id => consumption['product_category_id'], :product_id => product.id)
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
