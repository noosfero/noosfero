class ArticleCategorization < ActiveRecord::Base
  set_table_name :articles_categories
  belongs_to :article
  belongs_to :category

  after_create :associate_with_entire_hierarchy
  def associate_with_entire_hierarchy
    return if virtual

    c = category.parent
    while !c.nil? && !self.class.find(:first, :conditions => {:article_id => article, :category_id => c}) 
      self.class.create!(:article => article, :category => c, :virtual => true)
      c = c.parent
    end
  end

  def self.remove_all_for(article)
    self.delete_all(:article_id => article.id)
  end

end
