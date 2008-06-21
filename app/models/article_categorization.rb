class ArticleCategorization < ActiveRecord::Base
  set_table_name :articles_categories
  belongs_to :article
  belongs_to :category

  def self.add_category_to_article(category, article)
    connection.execute("insert into articles_categories (category_id, article_id) values(#{category.id}, #{article.id})")

    c = category.parent
    while !c.nil? && !self.find(:first, :conditions => {:article_id => article, :category_id => c})
      connection.execute("insert into articles_categories (category_id, article_id, virtual) values(#{c.id}, #{article.id}, 1>0)")
      c = c.parent
    end
  end

  def self.remove_all_for(article)
    self.delete_all(:article_id => article.id)
  end

end
