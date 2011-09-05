class Product < ActiveRecord::Base
  belongs_to :enterprise
  has_one :region, :through => :enterprise

  belongs_to :product_category

  has_many :inputs, :dependent => :destroy, :order => 'position'

  has_many :product_qualifiers, :dependent => :destroy
  has_many :qualifiers, :through => :product_qualifiers
  has_many :certifiers, :through => :product_qualifiers

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
    if self.lat != e.lat or self.lng != e.lng
      self.lat = e.lat
      self.lng = e.lng
      save!
    end
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
    discount ? price - discount : price
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

  def display_supplier_on_search?
    true
  end

  private
  def name_or_category
    name ? name : product_category.name
  end
  def price_sort
    (price.nil? or price.zero?) ? 999999999.9 : price
  end
  def f_category
    self.product_category.name
  end
  def f_region
    self.enterprise.region.id if self.enterprise.region
  end
  def self.f_region_proc(id)
    c = Region.find(id)
    s = c.parent
    if c and c.kind_of?(City) and s and s.kind_of?(State) and s.acronym 
      [c.name, ', ' + s.acronym]
    else
      c.name
    end
  end
  def self.f_qualifier_proc(id)
    pq = ProductQualifier.find(id)
    if pq.certifier
      [pq.qualifier.name, _(' cert. ') + pq.certifier.name]
    else
      pq.qualifier.name
    end
  end
  def f_qualifier
    product_qualifier_ids
  end
  public

  acts_as_faceted :fields => {
    :f_category => {:label => _('Related products')},
    :f_region => {:label => _('City'), :proc => proc { |id| f_region_proc(id) }},
    :f_qualifier => {:label => _('Qualifiers'), :proc => proc { |id| f_qualifier_proc(id) }}},
    :category_query => proc { |c| "f_category:\"#{c.name}\"" },
    :order => [:f_category, :f_region, :f_qualifier]

  acts_as_searchable :additional_fields => [
      {:name => {:type => :text, :boost => 5.0}},
      {:price_sort => {:type => :decimal}},
      {:name_or_category => {:type => :string, :as => :name_or_category_sort, :boost => 2.0}},
      :category_full_name ] + facets.keys.map{|i| {i => :facet}},
    :include => [:enterprise, :qualifiers, :certifiers, :product_category],
    :boost => proc {|p| 10 if p.enterprise.enabled},
    :facets => facets.keys
  handle_asynchronously :solr_save

end
