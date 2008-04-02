class Comment < ActiveRecord::Base
  
  acts_as_searchable :fields => [:title, :body]  
  
  validates_presence_of :title, :body
  belongs_to :article, :counter_cache => true
  belongs_to :author, :class_name => 'Person', :foreign_key => 'author_id'

  # unauthenticated authors:
  validates_presence_of :name, :if => (lambda { |record| !record.email.blank? })
  validates_presence_of :email, :if => (lambda { |record| !record.name.blank? })

  # require either a recognized author or an external person
  validates_presence_of :author_id, :if => (lambda { |rec| rec.name.blank? && rec.email.blank? })
  validates_each :name do |rec,attribute,value|
    if rec.author_id && (!rec.name.blank? || !rec.email.blank?)
      rec.errors.add(:name, _('%{fn} can only be informed for unauthenticated authors'))
    end
  end

  def author_name
    if author
      author.name
    else
      name
    end
  end

  def url
    article.url.merge(:anchor => anchor)
  end

  def anchor
    "comment-#{id}"
  end

  def self.recent(limit = nil)
    self.find(:all, :order => 'created_on desc, id desc', :limit => limit)
  end

end
