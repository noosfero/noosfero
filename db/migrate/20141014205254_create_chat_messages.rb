class CreateChatMessages < ActiveRecord::Migration
  def up
    create_table :chat_messages do |t|
      t.references :from, :null => false
      t.references :to, :null => false
      t.text   :body
      t.timestamps
    end
    add_index :chat_messages, :from_id
    add_index :chat_messages, :to_id
    add_index :chat_messages, :created_at
  end

  def down
    remove_index :chat_messages, :from_id
    remove_index :chat_messages, :to_id
    remove_index :chat_messages, :created_at
    drop_table :chat_messages
  end
end
