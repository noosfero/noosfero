class AddsMetadataToRoutes < ActiveRecord::Migration[5.1]
  def change
    add_column :custom_routes_plugin_routes, :metadata, :jsonb, default: {}
    add_index :custom_routes_plugin_routes, :metadata, using: :gin
  end
end
