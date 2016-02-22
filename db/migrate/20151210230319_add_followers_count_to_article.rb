class AddFollowersCountToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :followers_count, :integer, :default => 0
    execute "update articles set followers_count = (select count(*) from article_followers where article_followers.article_id = articles.id)"
  end

  def self.down
    remove_column :articles, :followers_count
  end
end
