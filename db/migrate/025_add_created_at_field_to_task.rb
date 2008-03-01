class AddCreatedAtFieldToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :created_at, :datetime
  end

  def self.down
    remove_column :tasks, :created_at
  end
end
