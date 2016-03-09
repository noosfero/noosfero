class AddIdToArticleFollower < ActiveRecord::Migration
  def change
    add_column :article_followers, :id, :primary_key
  end
end
