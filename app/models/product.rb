class Product < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :product_category

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :enterprise_id
  validates_numericality_of :price, :allow_nil => true

  after_update :save_image

  after_create do |p|
    p.enterprise.save if p.enterprise
  end

  after_update do |p|
    p.enterprise.save if p.enterprise
  end

  acts_as_searchable :fields => [ :name, :description, :category_full_name ]

  xss_terminate :only => [ :name, :description ]
  
  def category_full_name
    product_category.full_name(" ")
  end

  acts_as_having_image

  def save_image
    image.save if image
  end

  def category_name
    product_category ? product_category.name : _('Uncategorized product')
  end

  def self.recent(limit = nil)
    self.find(:all, :order => 'id desc', :limit => limit)
  end

  def self.find_by_initial(initial)
    self.find(:all, :order => 'products.name', :conditions => [ 'products.name like (?) or products.name like (?)', initial + '%', initial.upcase + '%'])
  end

end
