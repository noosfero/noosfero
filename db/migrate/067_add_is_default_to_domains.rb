class AddIsDefaultToDomains < ActiveRecord::Migration
  def self.up
    add_column :domains, :is_default, :boolean, :default => false
    execute('update domains set is_default = (1<0)') # set all to false
  end

  def self.down
    remove_column :domains, :is_default
  end
end
