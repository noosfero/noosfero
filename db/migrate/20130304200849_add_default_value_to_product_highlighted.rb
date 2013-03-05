class AddDefaultValueToProductHighlighted < ActiveRecord::Migration
  def self.up
    change_column :products, :highlighted, :boolean, :default => false
    execute('UPDATE products SET highlighted=(0>1) WHERE highlighted IS NULL;')
  end

  def self.down
    say 'This migraiton is not reversible!'
  end
end
