class AddMetadataToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :metadata, :jsonb, :default => {}
    add_index  :comments, :metadata, using: :gin
  end
end
