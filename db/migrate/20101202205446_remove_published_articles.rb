class RemovePublishedArticles < ActiveRecord::Migration
  def self.up
    select_all("SELECT * from articles WHERE type = 'PublishedArticle'").each do |published|
      reference = Article.exists?(published['reference_article_id']) ? Article.find(published['reference_article_id']) : nil
      if reference
        execute("UPDATE articles SET type = '#{reference.type}', abstract = '#{reference.abstract}', body = '#{reference.body}' WHERE articles.id  = #{published['id']}")
      else
        execute("DELETE from articles where articles.id  = #{published['id']}")
      end
    end
  end

  def self.down
    say 'Nothing to do'
  end
end
