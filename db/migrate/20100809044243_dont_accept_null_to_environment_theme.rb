class DontAcceptNullToEnvironmentTheme < ActiveRecord::Migration
  def self.up
    Environment.where(theme: nil).find_each do |environment|
      environment.update_attribute(:theme, 'default')
    end

    change_column :environments, :theme, :string, :default => 'default', :null => false
  end

  def self.down
    change_column :environments, :theme, :string, :default => nil, :null => true

    Environment.where(theme: 'default').find_each do |environment|
      environment.update_attribute(:theme, nil)
    end
  end
end
