# An enterprise is a kind of organization. According to the system concept,
# only enterprises can offer products and services.
class Enterprise < Organization

  attr_accessible :business_name, :address_reference, :district, :tag_list, :organization_website, :historic_and_current_context, :activities_short_description, :products_per_catalog_page

  SEARCH_FILTERS = {
    :order => %w[more_recent more_popular more_active],
    :display => %w[compact full map]
  }

  def self.type_name
    _('Enterprise')
  end

  N_('Enterprise')

  acts_as_trackable after_add: proc{ |p, t| notify_activity t }

  has_many :products, :foreign_key => :profile_id, :dependent => :destroy
  has_many :product_categories, :through => :products
  has_many :inputs, :through => :products
  has_many :production_costs, :as => :owner

  has_many :favorite_enterprise_people
  has_many :fans, source: :person, through: :favorite_enterprise_people

  N_('Organization website'); N_('Historic and current context'); N_('Activities short description'); N_('City'); N_('State'); N_('Country'); N_('ZIP code')

  settings_items :organization_website, :historic_and_current_context, :activities_short_description

  settings_items :products_per_catalog_page, :type => :integer, :default => 6
  alias_method :products_per_catalog_page_before_type_cast, :products_per_catalog_page
  validates_numericality_of :products_per_catalog_page, :allow_nil => true, :greater_than => 0

  extend SetProfileRegionFromCityState::ClassMethods
  set_profile_region_from_city_state

  before_save do |enterprise|
    enterprise.organization_website = enterprise.maybe_add_http(enterprise.organization_website)
  end
  include MaybeAddHttp

  def business_name
    self.nickname
  end
  def business_name=(value)
    self.nickname = value
  end
  N_('Business name')

  FIELDS = %w[
    business_name
    organization_website
    historic_and_current_context
    activities_short_description
    acronym
    foundation_year
  ]

  def self.fields
    super + FIELDS
  end

  def active_fields
    environment ? environment.active_enterprise_fields : []
  end

  def highlighted_products_with_image(options = {})
    Product.where(:highlighted => true).joins(:image)
  end

  def required_fields
    environment ? environment.required_enterprise_fields : []
  end

  def signup_fields
    environment ? environment.signup_enterprise_fields : []
  end

  def closed?
    true
  end

  def blocked?
    data[:blocked]
  end

  def block
    data[:blocked] = true
    save
  end

  def unblock
    data[:blocked] = false
    save
  end

  def activation_task
    self.tasks.where(:type => 'EnterpriseActivation').first
  end

  def enable(owner = nil)
    if owner.nil?
      self.visible = true
      return self.save
    end

    return if enabled
    # must be set first for the following to work
    self.enabled = true
    self.affiliate owner, Profile::Roles.all_roles(self.environment.id) if owner
    self.apply_template template if self.environment.replace_enterprise_template_when_enable
    self.activation_task.update_attribute :status, Task::Status::FINISHED rescue nil
    self.save(:validate => false)
  end

  def question
    if !self.foundation_year.blank?
      :foundation_year
    elsif !self.cnpj.blank?
      :cnpj
    else
      nil
    end
  end

  after_create :create_activation_task
  def create_activation_task
    if !self.enabled
      EnterpriseActivation.create!(:enterprise => self, :code_length => 7)
    end
  end

  def default_set_of_blocks
    links = [
      {:name => _("Enterprises's profile"), :address => '/profile/{profile}', :icon => 'ok'},
      {:name => _('Blog'), :address => '/{profile}/blog', :icon => 'edit'},
      {:name => _('Products'), :address => '/catalog/{profile}', :icon => 'new'},
    ]
    blocks = [
      [MainBlock.new],
      [ ProfileImageBlock.new,
        LinkListBlock.new(:links => links),
        ProductCategoriesBlock.new
      ],
      [LocationBlock.new]
    ]
    if environment.enabled?('products_for_enterprises')
      blocks[2].unshift ProductsBlock.new
    end
    blocks
  end

  def default_set_of_articles
    [
      Blog.new(:name => _('Blog')),
    ]
  end

  before_create do |enterprise|
    enterprise.validated = enterprise.environment.enabled?('enterprises_are_validated_when_created')
    if enterprise.environment.enabled?('enterprises_are_disabled_when_created')
      enterprise.enabled = false
    end
    true
  end

  def default_template
    environment.enterprise_default_template
  end

  def template_with_inactive_enterprise
    !enabled? ? environment.inactive_enterprise_template : template_without_inactive_enterprise
  end
  alias_method_chain :template, :inactive_enterprise

  def control_panel_settings_button
    {:title => _('Enterprise Info and settings'), :icon => 'edit-profile-enterprise'}
  end

  settings_items :enable_contact_us, :type => :boolean, :default => true

  def enable_contact?
    enable_contact_us
  end

  def control_panel_settings_button
    {:title => _('Enterprise Info and settings'), :icon => 'edit-profile-enterprise'}
  end

  def create_product?
    true
  end

  def catalog_url
    { :profile => identifier, :controller => 'catalog'}
  end

  def more_recent_label
    ''
  end

  def followed_by? person
    super or self.fans.where(id: person.id).count > 0
  end


end
