class AddDefaultValueForEnvironmentTheme < ActiveRecord::Migration
  def self.up
    change_column :environments, :theme, :string, :default => 'default'
  end

  def self.down
    change_column :environments, :theme, :string, :default => nil
  end
end
