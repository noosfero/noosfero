# An enterprise is a kind of organization. According to the system concept,
# only enterprises can offer products and services.
class Enterprise < Organization

  N_('Enterprise')

  has_many :products, :dependent => :destroy, :order => 'name ASC'

  extra_data_for_index :product_categories

  N_('Organization website'); N_('Historic and current context'); N_('Activities short description'); N_('City'); N_('State'); N_('Country'); N_('ZIP code')

  settings_items :organization_website, :historic_and_current_context, :activities_short_description, :zip_code, :city, :state, :country

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

  def validate
    super
    self.required_fields.each do |field|
      if self.send(field).blank?
        self.errors.add(field, _("%{fn} can't be blank"))
      end
    end
  end

  def active_fields
    environment ? environment.active_enterprise_fields : []
  end

  def highlighted_products_with_image(options = {})
    Product.find(:all, {:conditions => {:highlighted => true}, :joins => :image}.merge(options))
  end

  def required_fields
    environment ? environment.required_enterprise_fields : []
  end

  def signup_fields
    environment ? environment.signup_enterprise_fields : []
  end

  def product_categories
    products.map{|p| p.category_full_name}.compact
  end

  def product_updated
    ferret_update
  end

  after_save do |e|
    e.products.each{ |p| p.enterprise_updated(e) }
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

  def enable(owner)
    return if enabled
    affiliate(owner, Profile::Roles.all_roles(environment.id))
    update_attribute(:enabled,true)
    if environment.replace_enterprise_template_when_enable
      apply_template(template)
    end
    save_without_validation!
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
    blocks = [
      [MainBlock],
      [ProfileInfoBlock, MembersBlock],
      [RecentDocumentsBlock]
    ]
    if !environment.enabled?('disable_products_for_enterprises')
      blocks[2].unshift ProductsBlock
    end
    blocks
  end

  before_create do |enterprise|
    if enterprise.environment.enabled?('enterprises_are_disabled_when_created')
      enterprise.enabled = false
    end
    true
  end

  def template
    if enabled?
      environment.enterprise_template
    else
      environment.inactive_enterprise_template
    end
  end

  settings_items :enable_contact_us, :type => :boolean, :default => true

  def enable_contact?
    enable_contact_us
  end

  protected

  def default_homepage(attrs)
    EnterpriseHomepage.new(attrs)
  end

end
