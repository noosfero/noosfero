class Product < ActiveRecord::Base

  belongs_to :enterprise
  has_one :region, :through => :enterprise
  validates_presence_of :enterprise

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

  named_scope :more_recent, :order => "created_at DESC"

  named_scope :from_category, lambda { |category|
    {:joins => :product_category, :conditions => ['categories.path LIKE ?', "%#{category.slug}%"]} if category
  }

  after_update :save_image

  def lat
    self.enterprise.lat
  end
  def lng
    self.enterprise.lng
  end

  xss_terminate :only => [ :name ], :on => 'validation'
  xss_terminate :only => [ :description ], :with => 'white_list', :on => 'validation'

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
      self.product_qualifiers.create(:qualifier_id => qualifier_id, :certifier_id => certifier_id) if qualifier_id != 'nil'
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
    inputs.relevant_to_price.map(&:cost).inject { |sum,price| sum + price }
  end

  def total_production_cost
    return inputs_cost if price_details.empty?
    inputs_cost + price_details.map(&:price).inject(0){ |sum,price| sum + price }
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

  def percentage_from_solidarity_economy
    se_i = t_i = 0
    self.inputs(true).each{ |i| t_i += 1; se_i += 1 if i.is_from_solidarity_economy }
    t_i = 1 if t_i == 0 # avoid division by 0
    p = case (se_i.to_f/t_i)*100
        when 0 then [0, '']
        when 0..24.999 then [0, _("0%")];
        when 25..49.999 then [25, _("25%")];
        when 50..74.999 then [50, _("50%")];
        when 75..99.999 then [75, _("75%")];
        when 100 then [100, _("100%")];
        end
  end

  private
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
  def self.f_qualifier_proc(ids)
    array = ids.split
    qualifier = Qualifier.find_by_id array[0]
    certifier = Certifier.find_by_id array[1]
    certifier ? [qualifier.name, _(' cert. ') + certifier.name] : qualifier.name
  end
  def f_qualifier
    product_qualifiers.map do |pq|
      "#{pq.qualifier_id} #{pq.certifier_id}"
    end
  end

  alias_method :name_sortable, :name
  delegate :enabled, :region, :region_id, :environment, :environment_id, :to => :enterprise
  def name_sortable # give a different name for solr
    name
  end
  def public
    self.public?
  end
  def price_sortable
    (price.nil? or price.zero?) ? nil : price
  end
  def category_filter
    enterprise.categories_including_virtual_ids << product_category_id
  end
  public

  acts_as_faceted :fields => {
      :f_category => {:label => _('Related products')},
      :f_region => {:label => _('City'), :proc => proc { |id| f_region_proc(id) }},
      :f_qualifier => {:label => _('Qualifiers'), :proc => proc { |id| f_qualifier_proc(id) }},
    }, :category_query => proc { |c| "category_filter:#{c.id}" },
    :order => [:f_category, :f_region, :f_qualifier]

  Boosts = [
    [:image, 0.55, proc{ |p| p.image ? 1 : 0}],
    [:qualifiers, 0.45, proc{ |p| p.product_qualifiers.count > 0 ? 1 : 0}],
    [:open_price, 0.45, proc{ |p| p.price_described? ? 1 : 0}],
    [:solidarity, 0.45, proc{ |p| p.percentage_from_solidarity_economy[0].to_f/100 }],
    [:available, 0.35, proc{ |p| p.available ? 1 : 0}],
    [:price, 0.35, proc{ |p| (!p.price.nil? and p.price > 0) ? 1 : 0}],
    [:new_product, 0.35, proc{ |p| (p.updated_at.to_i - p.created_at.to_i) < 24*3600 ? 1 : 0}],
    [:description, 0.3, proc{ |p| !p.description.blank? ? 1 : 0}],
    [:enabled, 0.2, proc{ |p| p.enterprise.enabled ? 1 : 0}],
  ]

  acts_as_searchable :fields => facets_fields_for_solr + [
      # searched fields
      {:name => {:type => :text, :boost => 2.0}},
      {:description => :text}, {:category_full_name => :text},
      # filtered fields
      {:public => :boolean}, {:environment_id => :integer},
      {:enabled => :boolean}, {:category_filter => :integer},
      # ordered/query-boosted fields
      {:price_sortable => :decimal}, {:name_sortable => :string},
      {:lat => :float}, {:lng => :float},
      :updated_at, :created_at,
    ], :include => [
      {:product_category => {:fields => [:name, :path, :slug, :lat, :lng, :acronym, :abbreviation]}},
      {:region => {:fields => [:name, :path, :slug, :lat, :lng]}},
      {:enterprise => {:fields => [:name, :identifier, :address, :nickname, :lat, :lng]}},
      {:qualifiers => {:fields => [:name]}},
      {:certifiers => {:fields => [:name]}},
    ], :facets => facets_option_for_solr,
    :boost => proc{ |p| boost = 1; Boosts.each{ |b| boost = boost * (1 - ((1 - b[2].call(p)) * b[1])) }; boost}
  handle_asynchronously :solr_save
  after_save_reindex [:enterprise], :with => :delayed_job

end
