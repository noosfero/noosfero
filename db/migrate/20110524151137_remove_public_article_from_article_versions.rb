class RemovePublicArticleFromArticleVersions < ActiveRecord::Migration
  def self.up
    remove_column :article_versions, :public_article
  end

  def self.down
    add_column :article_versions, :public_article, :boolean, :default => true
    execute('update article_versions set public_article = (1>0)')
  end
end
