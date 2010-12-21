class RemovePublishedArticles < ActiveRecord::Migration
  def self.up
    select_all("SELECT * from articles WHERE type = 'PublishedArticle'").each do |published|
      reference = Article.exists?(published['reference_article_id']) ? Article.find(published['reference_article_id']) : nil
      if reference
        execute(ActiveRecord::Base.sanitize_sql(["UPDATE articles SET type = ?, abstract = ?, body = ? WHERE articles.id  = ?", reference[:type], reference.abstract, reference.body, published['id']]))
      else
        execute("DELETE from articles where articles.id  = #{published['id']}")
      end
    end
  end

  def self.down
    say 'Nothing to do'
  end
end
