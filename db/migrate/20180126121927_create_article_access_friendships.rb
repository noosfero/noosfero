class CreateArticleAccessFriendships < ActiveRecord::Migration[4.2]
  def up
    noosfero_env = ENV['RAILS_ENV']
    if noosfero_env != 'production'
      create_view :article_access_friendships, materialized: false
    else
      create_view :article_access_friendships, materialized: true
      ArticleAccessFriendship.refresh()
    end
  end

  def down
    noosfero_env = ENV['RAILS_ENV']
    materialized = noosfero_env == 'production'  ? true : false
    drop_view :article_access_friendships, materialized: materialized
  end
end
