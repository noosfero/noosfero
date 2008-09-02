class AddAcceptCommentsToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :accept_comments, :boolean, :default => true
    execute 'update articles set accept_comments = (1>0)'
    add_column :article_versions, :accept_comments, :boolean, :default => true
    execute 'update article_versions set accept_comments = (1>0)'
  end

  def self.down
    remove_column :articles, :accept_comments
    remove_column :article_versions, :accept_comments
  end
end
