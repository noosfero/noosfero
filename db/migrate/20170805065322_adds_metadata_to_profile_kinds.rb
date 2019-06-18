class AddsMetadataToProfileKinds < ActiveRecord::Migration[4.2]
  def change
    add_column :kinds, :metadata, :jsonb, default: {}
  end
end
