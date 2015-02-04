class AddShowToFollowersForArticle < ActiveRecord::Migration
  def up
    add_column :articles, :show_to_followers, :boolean, :default => false
  end

  def down
    remove_column :articles, :show_to_followers
  end
end
