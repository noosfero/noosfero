class AddThumbnailsProcessedToImage < ActiveRecord::Migration
  def self.up
     add_column :images, :thumbnails_processed, :boolean, :default => false
  end

  def self.down
     remove_column :images, :thumbnails_processed, :boolean, :default => false
  end
end
