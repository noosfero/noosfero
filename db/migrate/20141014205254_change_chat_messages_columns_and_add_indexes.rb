class ChangeChatMessagesColumnsAndAddIndexes < ActiveRecord::Migration
  def up
    change_table :chat_messages do |t|
      t.change :from_id, :integer, :null => false
      t.change :to_id, :integer, :null => false
      t.change :body, :text
    end
    add_index :chat_messages, :from_id
    add_index :chat_messages, :to_id
    add_index :chat_messages, :created_at
  end

  def down
    remove_index :chat_messages, :from_id
    remove_index :chat_messages, :to_id
    remove_index :chat_messages, :created_at
    change_table :chat_messages do |t|
      t.change :from_id, :integer, :null => true
      t.change :to_id, :integer, :null => true
      t.change :body, :string
    end
  end
end
