class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|

      # acts as filesystem
      t.column :name, :string
      t.column :slug, :string
      t.column :path, :text, :default => ''
      t.column :parent_id, :integer # acts as tree included

      # main data
      t.column :body, :text
      t.column :abstract, :text

      # belongs to profile
      t.column :profile_id, :integer

      # keep track of changes
      t.column :updated_on,  :datetime
      t.column :created_on,  :datetime 
      t.column :last_changed_by_id, :integer

      # acts as versioned
      t.column :version, :integer
      t.column :lock_version, :integer

      # single-table inheritance
      t.column :type, :string

      # attachment_fu data for all uploaded files
      t.column :size,         :integer  # file size in bytes
      t.column :content_type, :string   # mime type, ex: application/mp3
      t.column :filename,     :string   # sanitized filename

      # attachment_fu data for images
      t.column :height,       :integer  # in pixels
      t.column :width,        :integer  # in pixels

    end

    Article.create_versioned_table
  end

  def self.down
    Article.drop_versioned_table
    drop_table :articles
  end
end
