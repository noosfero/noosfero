class AddsCommentCountToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :comments_count, :integer, :default => 0
    add_column :article_versions, :comments_count, :integer

    execute "update articles set comments_count = (select count(*) from comments where comments.article_id = articles.id)"
  end

  def self.down
    remove_column :article_versions, :comments_count
    remove_column :articles, :comments_count
  end
end
