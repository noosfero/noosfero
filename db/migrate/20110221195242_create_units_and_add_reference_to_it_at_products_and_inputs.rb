class CreateUnitsAndAddReferenceToItAtProductsAndInputs < ActiveRecord::Migration
  def self.up
    create_table :units do |t|
      t.string :singular,        :null => false
      t.string :plural,          :null => false
      t.integer :position
      t.references :environment, :null => false
    end
    [:products, :inputs].each do |table_name|
      change_table table_name do |t|
        t.remove :unit
        t.references :unit
      end
    end
  end

  def self.down
    drop_table :units
    [:products, :inputs].each do |table_name|
      change_table table_name do |t|
        t.string :unit
        t.remove_references :unit
      end
    end
  end
end
