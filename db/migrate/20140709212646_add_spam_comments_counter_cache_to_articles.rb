class AddSpamCommentsCounterCacheToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :spam_comments_count, :integer, :default => 0
    add_column :article_versions, :spam_comments_count, :integer, :default => 0

    execute("SELECT comments.source_id as source_id, count(comments.id) as comments_count FROM comments LEFT OUTER JOIN articles ON articles.id = source_id WHERE comments.source_type = 'Article' AND comments.spam = true GROUP BY comments.source_id;").each do |data|
      execute("UPDATE articles SET spam_comments_count = '#{data['comments_count']}' WHERE id = #{data['source_id']}")
    end
  end

  def self.down
    remove_column :articles, :spam_comments_count
    remove_column :article_versions, :spam_comments_count
  end
end
