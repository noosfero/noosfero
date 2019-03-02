class AddParagraphUuidToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :paragraph_uuid, :string
    add_index :comments, :paragraph_uuid
  end
end
