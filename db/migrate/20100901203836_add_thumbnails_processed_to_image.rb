class AddThumbnailsProcessedToImage < ActiveRecord::Migration
  def self.up
     add_column :images, :thumbnails_processed, :boolean, :default => false
     # the pre-existing images already had their thumbnails created
     execute('update images set thumbnails_processed = (1>0)')
  end

  def self.down
     remove_column :images, :thumbnails_processed
  end
end
