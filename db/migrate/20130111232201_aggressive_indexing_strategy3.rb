class AggressiveIndexingStrategy3 < ActiveRecord::Migration
  def self.up
    add_index :articles, :slug
    add_index :articles, :parent_id
    add_index :articles, :profile_id
    add_index :articles, :translation_of_id

    add_index :article_versions, :article_id

    add_index :comments, [:source_id, :spam]
  end

  def self.down
    remove_index :articles, :slug
    remove_index :articles, :parent_id
    remove_index :articles, :profile_id
    remove_index :articles, :translation_of_id

    remove_index :article_versions, :article_id

    remove_index :comments, [:source_id, :spam]
  end
end
