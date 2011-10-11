class AddReportsLowerBoundToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :reports_lower_bound, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :environments, :reports_lower_bound
  end
end
