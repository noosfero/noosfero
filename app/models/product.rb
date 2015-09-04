class Product < ActiveRecord::Base

  SEARCHABLE_FIELDS = {
    :name => {:label => _('Name'), :weight => 10},
    :description => {:label => _('Description'), :weight => 1},
  }

  SEARCH_FILTERS = {
    :order => %w[more_recent],
    :display => %w[full map]
  }

  attr_accessible :name, :product_category, :profile, :profile_id, :enterprise,
    :highlighted, :price, :image_builder, :description, :available, :qualifiers, :unit_id, :discount, :inputs, :qualifiers_list

  def self.default_search_display
    'full'
  end

  belongs_to :profile
  # backwards compatibility
  belongs_to :enterprise, :foreign_key => :profile_id, :class_name => 'Profile'
  alias_method :enterprise=, :profile=
  alias_method :enterprise, :profile

  has_one :region, :through => :profile
  validates_presence_of :profile

  belongs_to :product_category

  has_many :inputs, :dependent => :destroy, :order => 'position'
  has_many :price_details, :dependent => :destroy
  has_many :production_costs, :through => :price_details

  has_many :product_qualifiers, :dependent => :destroy
  has_many :qualifiers, :through => :product_qualifiers
  has_many :certifiers, :through => :product_qualifiers

  acts_as_having_settings :field => :data

  track_actions :create_product, :after_create, :keep_params => [:name, :url ], :if => Proc.new { |a| a.is_trackable? }, :custom_user => :action_tracker_user
  track_actions :update_product, :before_update, :keep_params => [:name, :url], :if => Proc.new { |a| a.is_trackable? }, :custom_user => :action_tracker_user
  track_actions :remove_product, :before_destroy, :keep_params => [:name], :if => Proc.new { |a| a.is_trackable? }, :custom_user => :action_tracker_user

  validates_uniqueness_of :name, :scope => :profile_id, :allow_nil => true, :if => :validate_uniqueness_of_column_name?

  validates_presence_of :product_category_id
  validates_associated :product_category

  validates_numericality_of :price, :allow_nil => true
  validates_numericality_of :discount, :allow_nil => true

  scope :more_recent, :order => "created_at DESC"

  scope :from_category, lambda { |category|
    {:joins => :product_category, :conditions => ['categories.path LIKE ?', "%#{category.slug}%"]} if category
  }

  scope :visible_for_person, lambda { |person|
    joins('INNER JOIN "profiles" enterprises ON enterprises."id" = "products"."profile_id"')
    .joins('LEFT JOIN "role_assignments" ON ("role_assignments"."resource_id" = enterprises."id"
          AND "role_assignments"."resource_type" = \'Profile\') OR (
          "role_assignments"."resource_id" = enterprises."environment_id" AND
          "role_assignments"."resource_type" = \'Environment\' )')
    .joins('LEFT JOIN "roles" ON "role_assignments"."role_id" = "roles"."id"')
    .where(
      ['( (roles.key = ? OR roles.key = ?) AND role_assignments.accessor_type = \'Profile\' AND role_assignments.accessor_id = ? )
        OR
        ( ( ( role_assignments.accessor_type = \'Profile\' AND
              role_assignments.accessor_id = ? ) OR
            ( enterprises.public_profile = ? AND enterprises.enabled = ? ) ) AND
          ( enterprises.visible = ? ) )',
      'profile_admin', 'environment_administrator', person.id, person.id,
      true, true, true]
    ).uniq
  }

  after_update :save_image

  def lat
    self.profile.lat
  end
  def lng
    self.profile.lng
  end

  xss_terminate :only => [ :name ], :on => 'validation'
  xss_terminate :only => [ :description ], :with => 'white_list', :on => 'validation'

  belongs_to :unit

  include FloatHelper

  include WhiteListFilter
  filter_iframes :description

  def iframe_whitelist
    self.profile && self.profile.environment && self.profile.environment.trusted_sites_for_iframe
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

  def name_is_blank?
    self[:name].blank?
  end

  def default_image(size='thumb')
    image ? image.public_filename(size) : '/images/icons-app/product-default-pic-%s.png' % size
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
    self.profile.public_profile_url.merge(:controller => 'manage_products', :action => 'show', :id => id)
  end

  def public?
    self.profile.public?
  end

  def formatted_value(method)
    value = self[method] || self.send(method)
    ("%.2f" % value).to_s.gsub('.', self.profile.environment.currency_separator) if value
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
      if qualifier_id != 'nil'
        product_qualifier = ProductQualifier.new
        product_qualifier.product = self
        product_qualifier.qualifier_id = qualifier_id
        product_qualifier.certifier_id = certifier_id
        product_qualifier.save!
      end
    end
  end

  def order_inputs!(order = [])
    order.each_with_index do |input_id, array_index|
      input = self.inputs.find(input_id)
      input.position = array_index + 1
      input.save!
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
    (price - total_production_cost.to_f).zero?
  end

  def update_price_details(new_price_details)
    price_details.destroy_all
    new_price_details.each do |detail|
      price_details.create(detail)
    end
    reload # to remove temporary duplicated price_details
    price_details
  end

  def price_description_percentage
    return 0 if price.blank? || price.zero?
    total_production_cost * 100 / price
  end

  def available_production_costs
    self.profile.environment.production_costs + self.profile.production_costs
  end

  include Rails.application.routes.url_helpers
  def price_composition_bar_display_url
    url_for({:host => self.profile.default_hostname, :controller => 'manage_products', :action => 'display_price_composition_bar', :profile => self.profile.identifier, :id => self.id }.merge(Noosfero.url_options))
  end

  def inputs_cost_update_url
    url_for({:host => self.profile.default_hostname, :controller => 'manage_products', :action => 'display_inputs_cost', :profile => self.profile.identifier, :id => self.id }.merge(Noosfero.url_options))
  end

  def percentage_from_solidarity_economy
    se_i = t_i = 0
    self.inputs.each{ |i| t_i += 1; se_i += 1 if i.is_from_solidarity_economy }
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

  delegate :enabled, :region, :region_id, :environment, :environment_id, :to => :profile, allow_nil: true

  protected

  def validate_uniqueness_of_column_name?
    true
  end

  def is_trackable?
    # shopping_cart create products without profile
    self.profile.present?
  end

  def action_tracker_user
    self.profile
  end

end
