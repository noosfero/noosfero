class ExternalFeed < ActiveRecord::Base

  belongs_to :blog
  validates_presence_of :blog_id
  validates_presence_of :address, :if => lambda {|efeed| efeed.enabled}
  validates_uniqueness_of :blog_id

  def add_item(title, link, date, content)
    article = TinyMceArticle.new(:name => title, :profile => blog.profile, :body => content, :published_at => date, :source => link, :profile => blog.profile, :parent => blog)
    unless blog.children.exists?(:slug => article.slug)
      article.save!
    end
  end

  def clear
    # do nothing
  end
  def finish_fetch
    if self.only_once
      self.enabled = 'false'
    end
    self.save!
  end

  def limit
    0
  end

end
