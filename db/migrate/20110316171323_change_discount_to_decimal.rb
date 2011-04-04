class ChangeDiscountToDecimal < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.change :discount, :decimal
    end
  end

  def self.down
    change_table :products do |t|
      t.change :discount, :float
    end
  end
end
