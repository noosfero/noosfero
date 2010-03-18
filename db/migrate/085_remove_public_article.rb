class RemovePublicArticle < ActiveRecord::Migration
  def self.up
    remove_column :articles, :public_article
  end

  def self.down
    add_column :articles, :public_article, :boolean, :default => true
    execute('update articles set public_article = (1>0)')
  end
end
