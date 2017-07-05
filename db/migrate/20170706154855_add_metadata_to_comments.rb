class AddMetadataToComments < ActiveRecord::Migration
  def change
    add_column :comments, :metadata, :jsonb, :default => {}
    add_index  :comments, :metadata, using: :gin
  end
end
