class AddReplyToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :reply_of_id, :integer
  end

  def self.down
    remove_column :comments, :reply_of_id
  end
end
