class AddTypeColumnForTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :type, :string
  end

  def self.down
    remove_column :tasks, :type
  end
end
