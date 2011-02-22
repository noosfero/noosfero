class SetPublishedArticlesSource < ActiveRecord::Migration
  def self.up
    update("update articles set source = (select source from articles origin where origin.id = articles.reference_article_id) where articles.type = 'PublishedArticle';")
  end

  def self.down
    say "this migration can't be reverted"
  end
end
