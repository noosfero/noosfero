class AddPublicColumnToArticlesAndProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :public_profile, :boolean, :default => true
    execute("update profiles set public_profile = (1>0) where data not like '%public_profile: false%'")

    add_column :articles, :public_article, :boolean, :default => true
    execute('update articles set public_article = (1>0)')

    add_column :article_versions, :public_article, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :public_profile
    remove_column :articles, :public_article
    remove_column :article_versions, :public_article
  end
end
