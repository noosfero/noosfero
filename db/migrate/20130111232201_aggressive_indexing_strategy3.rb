class AggressiveIndexingStrategy3 < ActiveRecord::Migration
  def self.up
    add_index :articles, :slug
    add_index :articles, :parent_id
    add_index :articles, :profile_id
    add_index :articles, :name

    add_index :article_versions, :article_id

    add_index :comments, [:source_id, :spam]

    add_index :profiles, :identifier

    add_index :friendships, :person_id
    add_index :friendships, :friend_id
    add_index :friendships, [:person_id, :friend_id], :uniq => true

    add_index :external_feeds, :blog_id
  end

  def self.down
    remove_index :articles, :slug
    remove_index :articles, :parent_id
    remove_index :articles, :profile_id
    remove_index :articles, :name

    remove_index :article_versions, :article_id

    remove_index :comments, [:source_id, :spam]

    remove_index :profiles, :identifier

    remove_index :friendships, :person_id
    remove_index :friendships, :friend_id
    remove_index :friendships, [:person_id, :friend_id]

    remove_index :external_feeds, :blog_id
  end
end
