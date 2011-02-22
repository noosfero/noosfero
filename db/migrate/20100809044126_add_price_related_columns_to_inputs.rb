class AddPriceRelatedColumnsToInputs < ActiveRecord::Migration
  def self.up
    add_column :inputs, :position, :integer
    add_column :inputs, :unit, :string
    add_column :inputs, :price_per_unit, :decimal
    add_column :inputs, :amount_used, :decimal
    add_column :inputs, :relevant_to_price, :boolean, :default => true
    add_column :inputs, :is_from_solidarity_economy, :boolean, :default => false
  end

  def self.down
    remove_column :inputs, :position
    remove_column :inputs, :unit
    remove_column :inputs, :price_per_unit
    remove_column :inputs, :amount_used
    remove_column :inputs, :relevant_to_price
    remove_column :inputs, :is_from_solidarity_economy
  end
end
