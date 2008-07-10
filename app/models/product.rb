class Product < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :product_category
  has_many :product_categorizations

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :enterprise_id
  validates_numericality_of :price, :allow_nil => true

  after_update :save_image

  after_create do |p|
    if p.enterprise
      p['lat'] = p.enterprise.lat
      p['lng'] = p.enterprise.lng
    end
  end

  after_save do |p|
    p.enterprise.product_updated if p.enterprise
  end

  after_save do |p|
    if (p.product_category && !ProductCategorization.find(:first, :conditions => {:category_id => p.product_category.id, :product_id => p.id})) || (!p.product_category)
      ProductCategorization.remove_all_for(p)
      if p.product_category
        ProductCategorization.add_category_to_product(p.product_category, p)
      end
    end
  end

  acts_as_searchable :fields => [ :name, :description, :category_full_name ]

  xss_terminate :only => [ :name, :description ]

  acts_as_mappable
  
  def category_full_name
    product_category ? product_category.full_name.split('/') : nil
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

  def enterprise_updated(e)
    self.lat = e.lat
    self.lng = e.lng
    save!
  end

  def url
    enterprise.generate_url(:controller => 'catalog', :action => 'show', :id => id)
  end

end
