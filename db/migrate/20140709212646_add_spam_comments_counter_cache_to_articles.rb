class AddSpamCommentsCounterCacheToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :spam_comments_count, :integer, :default => 0
    add_column :article_versions, :spam_comments_count, :integer, :default => 0
    execute "update articles set spam_comments_count = (select count(*) from comments where comments.source_id = articles.id and comments.source_type = 'Article' and comments.spam = 't');"
  end

  def self.down
    remove_column :articles, :spam_comments_count
    remove_column :article_versions, :spam_comments_count
  end
end
