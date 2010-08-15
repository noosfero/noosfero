class SetAvailableToTrueByDefaultOnProducts < ActiveRecord::Migration
  def self.up
    change_column :products, :available, :boolean, :default => true
    execute('update products set available = (1=1)')
  end

  def self.down
    change_column :products, :available, :boolean, :default => false
  end
end
