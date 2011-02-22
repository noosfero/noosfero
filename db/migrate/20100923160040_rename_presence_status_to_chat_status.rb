class RenamePresenceStatusToChatStatus < ActiveRecord::Migration
  def self.up
    rename_column :users, :last_presence_status, :last_chat_status
    rename_column :users, :presence_status, :chat_status

    add_column :users, :chat_status_at, :datetime
  end

  def self.down
    rename_column :users, :last_chat_status, :last_presence_status
    rename_column :users, :chat_status, :presence_status

    remove_column :users, :chat_status_at
  end
end
