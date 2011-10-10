class AddBscToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :bsc_id, :integer
  end

  def self.down
    remove_column :tasks, :bsc_id
  end
end
