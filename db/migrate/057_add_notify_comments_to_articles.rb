class AddNotifyCommentsToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :notify_comments, :boolean, :default => false
    add_column :article_versions, :notify_comments, :boolean, :default => false
  end

  def self.down
    remove_column :articles, :notify_comments
    remove_column :article_versions, :notify_comments
  end
end
