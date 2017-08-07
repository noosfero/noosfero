class AddsMetadataToProfileKinds < ActiveRecord::Migration
  def change
    add_column :kinds, :metadata, :jsonb, default: {}
  end
end
