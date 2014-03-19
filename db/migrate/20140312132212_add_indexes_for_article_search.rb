class AddIndexesForArticleSearch < ActiveRecord::Migration
  def self.up
    add_index :articles, :created_at
    add_index :articles, :hits
    add_index :articles, :comments_count
  end

  def self.down
    remove_index :articles, :created_at
    remove_index :articles, :hits
    remove_index :articles, :comments_count
  end
end
