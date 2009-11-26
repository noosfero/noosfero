class Product < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :product_category
  has_many :product_categorizations

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :enterprise_id
  validates_numericality_of :price, :allow_nil => true

  after_update :save_image

  before_create do |p|
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
    enterprise.public_profile_url.merge(:controller => 'catalog', :action => 'show', :id => id)
  end

  def public?
    enterprise.public_profile
  end

  def price=(value)
    if value.is_a?(String)
      super(currency_to_float(value))
    else
      super(value)
    end
  end

  def currency_to_float( num )
    if num.count('.') == 1 && num.count(',') == 0
      # number like "12.34"
      return num.to_f
    end

    if num.count('.') == 0 && num.count(',') == 1
      # number like "12,34"
      return num.tr(',','.').to_f
    end

    if num.count('.') > 0 && num.count(',') > 0
      # number like "12.345.678,90" or "12,345,678.90"
      dec_sep = num.tr('0-9','')[-1].chr
      return num.tr('^0-9'+dec_sep,'').tr(dec_sep,'.').to_f
    end

    # if you are here is because there is only one
    # separator and this appears 2 times or more.
    # number like "12.345.678" or "12,345,678"

    return num.tr(',.','').to_f
  end

end
