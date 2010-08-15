class Product < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :product_category
  has_many :product_categorizations
  has_many :product_qualifiers
  has_many :qualifiers, :through => :product_qualifiers
  has_many :inputs, :dependent => :destroy

  validates_uniqueness_of :name, :scope => :enterprise_id, :allow_nil => true
  validates_presence_of :product_category_id
  validates_associated :product_category

  validates_numericality_of :price, :allow_nil => true
  validates_numericality_of :discount, :allow_nil => true

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

  xss_terminate :only => [ :name ], :on => 'validation'
  xss_terminate :only => [ :description ], :with => 'white_list', :on => 'validation'

  acts_as_mappable

  include WhiteListFilter
  filter_iframes :description, :whitelist => lambda { enterprise && enterprise.environment && enterprise.environment.trusted_sites_for_iframe }

  def self.units
    {
      _('Litre') => 'litre',
      _('Kilo')  => 'kilo',
      _('Meter') => 'meter',
      _('Unit')  => 'unit',
    }
  end

  def name
    self[:name].blank? ? category_name : self[:name]
  end

  def name=(value)
    if (value == category_name)
      self[:name] = nil
    else
      self[:name] = value
    end
  end

  def default_image(size='thumb')
    '/images/icons-app/product-default-pic-%s.png' % size
  end

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
    enterprise.public_profile_url.merge(:controller => 'manage_products', :action => 'show', :id => id)
  end

  def public?
    enterprise.public_profile
  end

  def formatted_value(value)
    ("%.2f" % self[value]).to_s.gsub('.', enterprise.environment.currency_separator) if self[value]
  end

  def price_with_discount
    price - discount if discount
  end

  def price=(value)
    if value.is_a?(String)
      super(currency_to_float(value))
    else
      super(value)
    end
  end

  def discount=(value)
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

  def has_basic_info?
    %w[description price].each do |field|
      return true if !self.send(field).blank?
    end
    false
  end

  def qualifiers_list=(qualifiers)
    self.product_qualifiers.delete_all
    qualifiers.each do |item|
      self.product_qualifiers.create(item[1]) if item[1].has_key?('qualifier_id')
    end
  end
end
