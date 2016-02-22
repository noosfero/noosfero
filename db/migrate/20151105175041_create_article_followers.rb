class CreateArticleFollowers < ActiveRecord::Migration
  def self.up
    execute("CREATE TABLE article_followers AS (SELECT profiles.id AS person_id, t.id AS article_id, clock_timestamp() AS since FROM (SELECT articles.id, regexp_split_to_table(replace(replace(substring(articles.setting FROM ':followers:[^:]*'), ':followers:', ''), '- ', ''), '\n') AS follower FROM articles) t INNER JOIN users ON users.email = follower INNER JOIN profiles ON users.id = profiles.user_id WHERE follower != '');")
    add_timestamps :article_followers
    add_index :article_followers, :person_id
    add_index :article_followers, :article_id
    add_index :article_followers, [:person_id, :article_id], :unique => true
  end

  def self.down
    drop_table :article_followers
  end
end
