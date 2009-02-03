class AddTargetTypeColumnForTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :target_type, :string
    execute "update tasks set target_type = 'Profile'"
  end

  def self.down
    remove_column :tasks, :target_type
  end
end
