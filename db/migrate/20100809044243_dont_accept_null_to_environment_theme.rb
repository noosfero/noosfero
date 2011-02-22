class DontAcceptNullToEnvironmentTheme < ActiveRecord::Migration
  def self.up
    Environment.all(:conditions => {:theme => nil}).each do |environment|
      environment.update_attribute(:theme, 'default')
    end

    change_column :environments, :theme, :string, :default => 'default', :null => false
  end

  def self.down
    change_column :environments, :theme, :string, :default => nil, :null => true

    Environment.all(:conditions => {:theme => 'default'}).each do |environment|
      environment.update_attribute(:theme, nil)
    end
  end
end
