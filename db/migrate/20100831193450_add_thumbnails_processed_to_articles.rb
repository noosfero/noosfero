class AddThumbnailsProcessedToArticles < ActiveRecord::Migration
  def self.up
     add_column :articles, :thumbnails_processed, :boolean, :default => false
     add_column :article_versions, :thumbnails_processed, :boolean, :default => false
  end

  def self.down
     remove_column :articles, :thumbnails_processed
     remove_column :article_versions, :thumbnails_processed
  end
end
