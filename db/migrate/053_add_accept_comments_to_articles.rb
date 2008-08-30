class AddAcceptCommentsToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :accept_comments, :boolean, :default => true
    add_column :article_versions, :accept_comments, :boolean, :default => true
  end

  def self.down
    remove_column :articles, :accept_comments
    remove_column :article_versions, :accept_comments
  end
end
