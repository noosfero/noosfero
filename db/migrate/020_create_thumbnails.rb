class CreateThumbnails < ActiveRecord::Migration
  def self.up
    create_table :thumbnails do |t|
      # attachment_fu data for all uploaded files
      t.column :size,         :integer  # file size in bytes
      t.column :content_type, :string   # mime type, ex: application/mp3
      t.column :filename,     :string   # sanitized filename

      # attachment_fu data for images
      t.column :height,       :integer  # in pixels
      t.column :width,        :integer  # in pixels

      # attachment_fu data for thumbnails
      t.column :parent_id,    :integer  # id of parent image (on the same table, a self-referencing foreign-key).
      t.column :thumbnail,    :string   # the 'type' of thumbnail this attachment record describes.
    end
  end

  def self.down
    drop_table :thumbnails
  end
end
