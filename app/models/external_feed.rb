class ExternalFeed < ActiveRecord::Base

  belongs_to :blog
  validates_presence_of :blog_id
  validates_presence_of :address, :if => lambda {|efeed| efeed.enabled}
  validates_uniqueness_of :blog_id

  scope :enabled, :conditions => { :enabled => true }
  scope :expired, lambda {
    { :conditions => ['(fetched_at is NULL) OR (fetched_at < ?)', Time.now - FeedUpdater.update_interval] }
  }

  attr_accessible :address, :enabled

  def add_item(title, link, date, content)
    doc = Hpricot(content)
    doc.search('*').each do |p|
      if p.instance_of? Hpricot::Elem
        p.remove_attribute 'style'
        p.remove_attribute 'class'
      end
    end
    content = doc.to_s

    article = TinyMceArticle.new
    article.name = title
    article.profile = blog.profile
    article.body = content 
    article.published_at = date 
    article.source = link 
    article.profile = blog.profile 
    article.parent = blog
    unless blog.children.exists?(:slug => article.slug)
      article.save!
      article.delay.create_activity
    end
    article.valid?
  end

  def address=(new_address)
    self.fetched_at = nil unless address == new_address
    super(new_address)
  end

  def clear
    # do nothing
  end

  def finish_fetch
    if self.only_once && self.update_errors.zero?
      self.enabled = false
    end
    self.fetched_at = Time.now
    self.save!
  end

  def limit
    0
  end

end
