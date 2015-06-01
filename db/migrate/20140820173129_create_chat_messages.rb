class CreateChatMessages < ActiveRecord::Migration
  def up
    create_table :chat_messages do |t|
      t.integer :to_id
      t.integer :from_id
      t.string :body

      t.timestamps
    end
  end

  def down
    drop_table :chat_messages
  end
end
