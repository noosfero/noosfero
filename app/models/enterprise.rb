class Enterprise < Organization
  attr_accessible :business_name, :address_reference, :district,
                  :organization_website, :historic_and_current_context,
                  :activities_short_description

  SEARCH_FILTERS = {
    order: %w[more_recent more_popular more_active],
    display: %w[compact full map]
  }

  def self.type_name
    _("Enterprise")
  end

  N_("enterprise")

  acts_as_trackable after_add: proc { |p, t| notify_activity t }

  has_many :favorite_enterprise_people
  has_many :fans, source: :person, through: :favorite_enterprise_people

  N_("Organization website"); N_("Historic and current context"); N_("Activities short description"); N_("City"); N_("State"); N_("Country"); N_("ZIP code")

  settings_items :organization_website, :historic_and_current_context, :activities_short_description

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
  N_("Business name")

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
    self.tasks.where(type: "EnterpriseActivation").first
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
    self.save(validate: false)
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
      EnterpriseActivation.create!(enterprise: self, code_length: 7)
    end
  end

  def default_set_of_blocks
    links = [
      { name: _("Enterprises's profile"), address: "/profile/{profile}", icon: "enterprise" },
      { name: _("Blog"),                  address: "/{profile}/blog",    icon: "blog" }
    ]
    blocks = [
      [MainBlock.new],
      [ProfileImageBlock.new,
       LinkListBlock.new(links: links),],
      [LocationBlock.new]
    ]
    blocks
  end

  def default_set_of_articles
    [
      Blog.new(name: _("Blog")),
    ]
  end

  before_create do |enterprise|
    enterprise.validated = enterprise.environment.enabled?("enterprises_are_validated_when_created")
    if enterprise.environment.enabled?("enterprises_are_disabled_when_created")
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
  alias_method :template_without_inactive_enterprise, :template
  alias_method :template, :template_with_inactive_enterprise

  settings_items :enable_contact_us, type: :boolean, default: true

  def enable_contact?
    enable_contact_us
  end

  def more_recent_label
    ""
  end

  def available_blocks(person)
    super(person) + [DisabledEnterpriseMessageBlock, HighlightsBlock, FansBlock]
  end
end
