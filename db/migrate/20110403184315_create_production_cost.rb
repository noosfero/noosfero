class CreateProductionCost < ActiveRecord::Migration
  def self.up
    create_table :production_costs do |t|
      t.string :name
      t.references :owner, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :production_costs
  end
end
