class AddGroupIdToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :group_id, :integer
  end

  def self.down
    remove_column :comments, :group_id
  end
end
