class CreatePgSearchPluginSearchFacetOccurrences < ActiveRecord::Migration
  def change
    create_table :pg_search_plugin_search_facet_occurrences do |t|
      t.references :environment
      t.string :asset
      t.references :target, polymorphic: true
      t.string :attribute_name
      t.string :value
      t.timestamps
    end
  end
end
