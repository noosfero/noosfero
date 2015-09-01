class AddStoryAndPublishedAtToOpenGraphPluginActivity < ActiveRecord::Migration

  def change
    add_column :open_graph_plugin_tracks, :published_at, :datetime
    add_column :open_graph_plugin_tracks, :story, :string
    add_index :open_graph_plugin_tracks, :published_at
    add_index :open_graph_plugin_tracks, :story
  end

end
