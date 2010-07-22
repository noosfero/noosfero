class CreateInputs < ActiveRecord::Migration
  def self.up
    create_table :inputs do |t|
      t.references :product, :null => false
      t.references :product_category, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :inputs
  end
end
