class Product < ActiveRecord::Base
  belongs_to :enterprise
  belongs_to :product_category
  has_many :product_categorizations
  has_many :product_qualifiers
  has_many :qualifiers, :through => :product_qualifiers
  has_many :inputs, :dependent => :destroy, :order => 'position'
  has_many :price_details, :dependent => :destroy
  has_many :production_costs, :through => :price_details

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

  belongs_to :unit

  include FloatHelper

  include WhiteListFilter
  filter_iframes :description, :whitelist => lambda { enterprise && enterprise.environment && enterprise.environment.trusted_sites_for_iframe }

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

  def name_is_blank?
    self[:name].blank?
  end

  def default_image(size='thumb')
    image ? image.public_filename(size) : '/images/icons-app/product-default-pic-%s.png' % size
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

  def formatted_value(method)
    value = self[method] || self.send(method)
    ("%.2f" % value).to_s.gsub('.', enterprise.environment.currency_separator) if value
  end

  def price_with_discount
    price - discount if discount
  end

  def price=(value)
    if value.is_a?(String)
      super(decimal_to_float(value))
    else
      super(value)
    end
  end

  def discount=(value)
    if value.is_a?(String)
      super(decimal_to_float(value))
    else
      super(value)
    end
  end

  def has_basic_info?
    %w[unit price discount].each do |field|
      return true if !self.send(field).blank?
    end
    false
  end

  def qualifiers_list=(qualifiers)
    self.product_qualifiers.destroy_all
    qualifiers.each do |qualifier_id, certifier_id|
      self.product_qualifiers.create(:qualifier_id => qualifier_id, :certifier_id => certifier_id)
    end
  end

  def order_inputs!(order = [])
    order.each_with_index do |input_id, array_index|
      self.inputs.find(input_id).update_attributes(:position => array_index + 1)
    end
  end

  def name_with_unit
    unit.blank? ? name : "#{name} - #{unit.name.downcase}"
  end

  def inputs_cost
    return 0 if inputs.empty?
    inputs.map(&:cost).inject { |sum,price| sum + price }
  end

  def total_production_cost
    return inputs_cost if price_details.empty?
    inputs_cost + price_details.map(&:price).inject { |sum,price| sum + price }
  end

  def price_described?
    return false if price.nil?
    (price - total_production_cost).zero?
  end

  def update_price_details(price_details)
    self.price_details.destroy_all
    price_details.each do |price_detail|
      self.price_details.create(price_detail)
    end
  end

  def available_production_costs
    self.enterprise.environment.production_costs + self.enterprise.production_costs
  end

end
