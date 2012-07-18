class DropProductCategorization < ActiveRecord::Migration
  def self.up
    drop_table :product_categorizations
  end

  def self.down
    say "this migration can't be reverted"
  end
end
