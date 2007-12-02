class CreateConsumptions < ActiveRecord::Migration
  def self.up
    create_table :consumptions do |t|
      t.column :product_category_id,     :integer
      t.column :profile_id,              :integer

      t.column :aditional_specifications, :text
    end
  end

  def self.down
    drop_table :consumptions
  end
end
