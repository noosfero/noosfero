class Product < ActiveRecord::Base
  belongs_to :enterprise
  has_one :region, :through => :enterprise

  belongs_to :product_category

  has_many :inputs, :dependent => :destroy, :order => 'position'
  has_many :price_details, :dependent => :destroy
  has_many :production_costs, :through => :price_details

  has_many :product_qualifiers, :dependent => :destroy
  has_many :qualifiers, :through => :product_qualifiers
  has_many :certifiers, :through => :product_qualifiers

  validates_uniqueness_of :name, :scope => :enterprise_id, :allow_nil => true
  validates_presence_of :product_category_id
  validates_associated :product_category

  validates_numericality_of :price, :allow_nil => true
  validates_numericality_of :discount, :allow_nil => true

  named_scope :more_recent, :order => "updated_at DESC"

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
    enterprise.public?
  end

  def formatted_value(method)
    value = self[method] || self.send(method)
    ("%.2f" % value).to_s.gsub('.', enterprise.environment.currency_separator) if value
  end

  def price_with_discount
    discount ? (price - discount) : price
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

  # Note: will probably be completely overhauled for AI1413
  def inputs_prices?
    return false if self.inputs.count <= 0
    self.inputs.each do |input|
      return false if input.has_price_details? == false
    end
    true
  end

  def any_inputs_details?
    return false if self.inputs.count <= 0
    self.inputs.each do |input|
      return true if input.has_all_price_details? == true
    end
    false
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

  def inputs_cost
    return 0 if inputs.empty?
    inputs.map(&:cost).inject { |sum,price| sum + price }
  end

  def total_production_cost
    return inputs_cost if price_details.empty?
    inputs_cost + price_details.map(&:price).inject { |sum,price| sum + price }
  end

  def price_described?
    return false if price.blank? or price == 0
    (price - total_production_cost).zero?
  end

  def update_price_details(price_details)
    self.price_details.destroy_all
    price_details.each do |price_detail|
      self.price_details.create(price_detail)
    end
  end

  def price_description_percentage
    return 0 if price.blank? || price.zero?
    total_production_cost * 100 / price
  end

  def available_production_costs
    self.enterprise.environment.production_costs + self.enterprise.production_costs
  end

  include ActionController::UrlWriter
  def price_composition_bar_display_url
    url_for({:host => enterprise.default_hostname, :controller => 'manage_products', :action => 'display_price_composition_bar', :profile => enterprise.identifier, :id => self.id }.merge(Noosfero.url_options))
  end

  def inputs_cost_update_url
    url_for({:host => enterprise.default_hostname, :controller => 'manage_products', :action => 'display_inputs_cost', :profile => enterprise.identifier, :id => self.id }.merge(Noosfero.url_options))
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
  def public
    self.public?
  end
  def environment_id
    enterprise.environment_id
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
      {:public => {:type => :boolean}},
      {:environment_id => {:type => :integer}},
      {:name_or_category => {:type => :string, :as => :name_or_category_sort, :boost => 2.0}},
      :category_full_name ] + facets.keys.map{|i| {i => :facet}},
    :include => [:enterprise, :qualifiers, :certifiers, :product_category],
    :boost => proc {|p| 10 if p.enterprise.enabled},
    :facets => facets.keys
  handle_asynchronously :solr_save

end
