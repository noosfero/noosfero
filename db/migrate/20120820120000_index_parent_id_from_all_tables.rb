class IndexParentIdFromAllTables < ActiveRecord::Migration
  def self.up
    add_index :article_versions, :parent_id
    add_index :categories, :parent_id
    add_index :images, :parent_id
    add_index :tags, :parent_id
    add_index :thumbnails, :parent_id
  end

  def self.down
    remove_index :article_versions, :parent_id
    remove_index :categories, :parent_id
    remove_index :images, :parent_id
    remove_index :tags, :parent_id
    remove_index :thumbnails, :parent_id
  end
end
