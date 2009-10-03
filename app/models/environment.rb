# A Environment is like a website to be hosted in the platform. It may
# contain multiple Profile's and can be identified by several different
# domains.
class Environment < ActiveRecord::Base

  self.partial_updates = false

  has_many :tasks, :dependent => :destroy, :as => 'target'

  PERMISSIONS['Environment'] = {
    'view_environment_admin_panel' => N_('View environment admin panel'),
    'edit_environment_features' => N_('Edit environment features'),
    'edit_environment_design' => N_('Edit environment design'),
    'manage_environment_categories' => N_('Manage environment categories'),
    'manage_environment_roles' => N_('Manage environment roles'),
    'manage_environment_validators' => N_('Manage environment validators'),
  }

  module Roles
    def self.admin(env_id)
      Role.find_by_key_and_environment_id('environment_administrator', env_id)
    end
  end

  after_create do |e|
    Role.create!(
      :key => 'environment_administrator',
      :name => N_('Environment Administrator'),
      :environment => e,
      :permissions => [
        'view_environment_admin_panel',
        'edit_environment_features',
        'edit_environment_design',
        'manage_environment_categories',
        'manage_environment_roles',
        'manage_environment_validators',
        'edit_profile',
        'destroy_profile',
        'manage_memberships',
        'post_content',
        'edit_profile_design',
        'manage_products',
        'edit_appearance',
        'manage_friends',
        'validate_enterprise',
        'perform_task',
      ]
    )
    Role.create!(
      :key => 'profile_admin',
      :name => N_('Profile Administrator'),
      :environment => e,
      :permissions => [
        'edit_profile',
        'destroy_profile',
        'manage_memberships',
        'post_content',
        'edit_profile_design',
        'manage_products',
        'edit_appearance',
      ]
    )
    # members for enterprises, communities etc
    Role.create!(
      :key => "profile_member",
      :name => N_('Member'),
      :environment => e,
      :permissions => [
        'edit_profile',
        'post_content',
        'manage_products'
      ]
    )
    # moderators for enterprises, communities etc
    Role.create!(
      :key => 'profile_moderator',
      :name => N_('Moderator'),
      :environment => e,
      :permissions => [
        'manage_memberships',
        'edit_profile_design',
        'manage_products',
        'manage_friends',
        'perform_task'
      ]
    )
  end

  def add_admin(user)
    self.affiliate(user, Environment::Roles.admin(self.id))
  end

  def admins
    self.members_by_role(Environment::Roles.admin(self.id))
  end

  # returns the available features for a Environment, in the form of a
  # hash, with pairs in the form <tt>'feature_name' => 'Feature name'</tt>.
  def self.available_features
    {
      'disable_asset_articles' => _('Disable search for articles '),
      'disable_asset_enterprises' => __('Disable search for enterprises'),
      'disable_asset_people' => _('Disable search for people'),
      'disable_asset_communities' => __('Disable search for communities'),
      'disable_asset_products' => _('Disable search for products'),
      'disable_asset_events' => _('Disable search for events'),
      'disable_products_for_enterprises' => _('Disable products for enterprises'),
      'disable_categories' => _('Disable categories'),
      'disable_cms' => _('Disable CMS'),
      'disable_header_and_footer' => _('Disable header/footer editing by users'),
      'disable_gender_icon' => _('Disable gender icon'),
      'disable_categories_menu' => _('Disable the categories menu'),
      'disable_select_city_for_contact' => _('Disable state/city select for contact form'),
      'disable_contact_person' => _('Disable contact for people'),
      'disable_contact_community' => _('Disable contact for groups/communities'),
      'join_community_popup' => _('Ask users to join a group/community with a popup'),

      'enterprise_activation' => _('Enable activation of enterprises'),
      'warn_obsolete_browser' => _('Enable warning of obsolete browser'),
      'wysiwyg_editor_for_environment_home' => _('Use WYSIWYG editor to edit environment home page'),
      'media_panel' => _('Media panel in WYSIWYG editor'),
      'select_preferred_domain' => _('Select preferred domains per profile'),
      'display_wizard_signup' => _('Display wizard signup'),
      'use_portal_community' => _('Use the portal as news source for front page'),
      'user_themes' => _('Allow users to create their own themes'),
      'search_in_home' => _("Display search form in home page"),

      'cant_change_homepage' => _("Don't allow users to change which article to use as homepage"),
      'display_header_footer_explanation' => _("Display explanation about header and footer"),
      'articles_dont_accept_comments_by_default' => _("Articles don't accept comments by default"),
      'organizations_are_moderated_by_default' => _("Organizations have moderated publication by default"),
      'enable_organization_url_change' => _("Allow organizations to change their address"),
    }
  end

  # #################################################
  # Relationships and applied behaviour
  # #################################################

  acts_as_having_boxes

  after_create do |env|
    3.times do
      env.boxes << Box.new
    end

    # main area
    env.boxes[0].blocks << MainBlock.new

    # "left" area
    env.boxes[1].blocks << LoginBlock.new
    env.boxes[1].blocks << EnvironmentStatisticsBlock.new
    env.boxes[1].blocks << RecentDocumentsBlock.new

    # "right" area
    env.boxes[2].blocks << ProfileListBlock.new
  end

  # One Environment can be reached by many domains
  has_many :domains, :as => :owner
  has_many :profiles

  has_many :organizations
  has_many :enterprises
  has_many :products, :through => :enterprises
  has_many :people
  has_many :communities

  has_many :categories
  has_many :display_categories, :class_name => 'Category', :conditions => 'display_color is not null and parent_id is null', :order => 'display_color'

  has_many :regions

  has_many :roles

  acts_as_accessible

  def superior_intances
    [self, nil]
  end
  # #################################################
  # Attributes
  # #################################################

  # store the Environment settings as YAML-serialized Hash.
  serialize :settings

  def homepage
     settings[:homepage]
  end

  # returns a Hash containing the Environment configuration
  def settings
    self[:settings] ||= {}
  end

  # Enables a feature identified by its name
  def enable(feature)
    self.settings["#{feature}_enabled"] = true
  end

  # Disables a feature identified by its name
  def disable(feature)
    self.settings["#{feature}_enabled"] = false
  end

  # Tells if a feature, identified by its name, is enabled
  def enabled?(feature)
    self.settings["#{feature}_enabled"] == true
  end

  # enables the features identified by <tt>features</tt>, which is expected to
  # be an Enumarable object containing the identifiers of the desired features.
  # Passing <tt>nil</tt> is the same as passing an empty Array.
  def enabled_features=(features)
    features ||= []
    self.class.available_features.keys.each do |feature|
      if features.include? feature
        self.enable(feature)
      else
        self.disable(feature)
      end
    end
  end

  # the environment's terms of use: every user must accept them before
  # registering.
  def terms_of_use
    self.settings['terms_of_use']
  end

  # sets the environment's terms of use.
  def terms_of_use=(value)
    self.settings['terms_of_use'] = value
  end

  # returns <tt>true</tt> if this Environment has terms of use to be
  # accepted by users before registration.
  def has_terms_of_use?
    ! self.settings['terms_of_use'].nil?
  end

  # the environment's terms of enterprise use: every enterprise member must accept them before
  # registering or activating enterprises.
  def terms_of_enterprise_use
    self.settings['terms_of_enterprise_use']
  end

  # sets the environment's terms of enterprise use.
  def terms_of_enterprise_use=(value)
    self.settings['terms_of_enterprise_use'] = value
  end

  # returns <tt>true</tt> if this Environment has terms of enterprise use to be
  # accepted by users before registration or activation of enterprises.
  def has_terms_of_enterprise_use?
    ! self.settings['terms_of_enterprise_use'].blank?
  end

  def activation_blocked_text
    self.settings['activation_blocked_text']
  end
  
  def activation_blocked_text= value
    self.settings['activation_blocked_text'] = value
  end

  def message_for_disabled_enterprise
    self.settings['message_for_disabled_enterprise']
  end

  def message_for_disabled_enterprise=(value)
    self.settings['message_for_disabled_enterprise'] = value
  end

  # returns the approval method used for this environment. Possible values are:
  #
  # Defaults to <tt>:admim</tt>.
  def organization_approval_method
    self.settings['organization_approval_method'] || :admin
  end

  # Sets the organization_approval_method. Only accepts the following values:
  #
  # * <tt>:admin</tt>: organization registration must be approved by the
  #   environment administrator.
  # * <tt>:region</tt>: organization registering must be approved by some other
  #   organization asssigned as validator to the Region the new organization
  #   belongs to.
  #
  # Trying to set organization_approval_method to any other value will raise an
  # ArgumentError.
  #
  # The value passed as argument is converted to a Symbol before being actually
  # set to this setting.
  def organization_approval_method=(value)
    actual_value = value.to_sym

    accepted_values = %w[
      admin
      region
    ].map(&:to_sym)
    raise ArgumentError unless accepted_values.include?(actual_value)

    self.settings['organization_approval_method'] = actual_value
  end

  # the description of the environment. Normally used in the homepage.
  def description
    self.settings[:description]
  end

  # sets the #description of the environment
  def description=(value)
    self.settings[:description] = value
  end

  def terminology
    if self.settings[:terminology]
      self.settings[:terminology].constantize.instance
    else
      Noosfero.terminology
    end
  end

  def terminology=(value)
    if value
      self.settings[:terminology] = value.class.name
    else
      self.settings[:terminology] = nil
    end
  end

  def custom_person_fields
    self.settings[:custom_person_fields].nil? ? {} : self.settings[:custom_person_fields]
  end

  def custom_person_fields=(values)
    if values['schooling'] && values['schooling']['active'] == 'true'
      schooling_status = values['schooling']
    end
    self.settings[:custom_person_fields] = values.delete_if { |key, value| ! Person.fields.include?(key)}
    if schooling_status
      self.settings[:custom_person_fields]['schooling_status'] = schooling_status
    end
  end

  def custom_person_field(field, status)
    if (custom_person_fields[field] && custom_person_fields[field][status] == 'true') 
      return true
    end
    false
  end

  def active_person_fields
    (custom_person_fields.delete_if { |key, value| !custom_person_field(key, 'active')}).keys || []
  end

  def required_person_fields
    required_fields = []
    active_person_fields.each do |field|
      required_fields << field if custom_person_fields[field]['required'] == 'true'
    end
    required_fields
  end

  def signup_person_fields
    signup_fields = []
    active_person_fields.each do |field|
      signup_fields << field if custom_person_fields[field]['signup'] == 'true'
    end
    signup_fields
  end

  # Default message send to friend when user use invite a friend feature
  def message_for_friend_invitation
    self.settings['message_for_friend_invitation'] || [
      _('Hello <friend>,'),
      _('<user> is inviting you to participate on %{environment}.') % { :environment => self.name },
      _('To accept the invitation, please follow this link:') + "\n" + '<url>',
      "--\n#{self.name}",
      ''
    ].join("\n\n")
  end

  def message_for_friend_invitation=(value)
    self.settings['message_for_friend_invitation'] = value
  end

  def custom_enterprise_fields
    self.settings[:custom_enterprise_fields].nil? ? {} : self.settings[:custom_enterprise_fields]
  end

  def custom_enterprise_fields=(values)
    self.settings[:custom_enterprise_fields] = values.delete_if { |key, value| ! Enterprise.fields.include?(key)}
  end

  def custom_enterprise_field(field, status)
    if (custom_enterprise_fields[field] && custom_enterprise_fields[field][status] == 'true') 
      return true
    end
    false
  end

  def active_enterprise_fields
     (custom_enterprise_fields.delete_if { |key, value| !custom_enterprise_field(key, 'active')}).keys || []
  end

  def required_enterprise_fields
    required_fields = []
    active_enterprise_fields.each do |field|
      required_fields << field if custom_enterprise_fields[field]['required'] == 'true'
    end
    required_fields
  end

  def custom_community_fields
    self.settings[:custom_community_fields].nil? ? {} : self.settings[:custom_community_fields]
  end

  def custom_community_fields=(values)
    self.settings[:custom_community_fields] = values.delete_if { |key, value| ! Community.fields.include?(key) }
  end

  def custom_community_field(field, status)
    if (custom_community_fields[field] && custom_community_fields[field][status] == 'true') 
      return true
    end
    false
  end

  def active_community_fields
    (custom_community_fields.delete_if { |key, value| !custom_community_field(key, 'active')}).keys
  end

  def required_community_fields
    required_fields = []
    active_community_fields.each do |field|
      required_fields << field if custom_community_fields[field]['required'] == 'true'
    end
    required_fields
  end

  def category_types
    self.settings[:category_types].nil? ? ['Category'] : self.settings[:category_types]
  end

  def category_types=(values)
    self.settings[:category_types] = values
  end

  # Whether this environment should force having 'www.' in its domain name or
  # not. Defauls to false.
  #
  # See also #default_hostname
  def force_www
    settings[:force_www] || false
  end

  # Sets the value of #force_www. <tt>value</tt> must be a boolean.
  def force_www=(value)
    settings[:force_www] = value
  end

  # #################################################
  # Validations
  # #################################################

  # <tt>name</tt> is mandatory
  validates_presence_of :name

  # only one environment can be the default one
  validates_uniqueness_of :is_default, :if => (lambda do |environment| environment.is_default? end), :message => N_('Only one Virtual Community can be the default one')

  validates_format_of :contact_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |record| ! record.contact_email.blank? })

  xss_terminate :only => [ :message_for_disabled_enterprise ], :with => 'white_list'


  # #################################################
  # Business logic in general
  # #################################################

  # the default Environment.
  def self.default
    self.find(:first, :conditions => [ 'is_default = ?', true ] )
  end

  # returns an array with the top level categories for this environment. 
  def top_level_categories
    Category.top_level_for(self)
  end

  # Returns the hostname of the first domain associated to this environment.
  #
  # If #force_www is true, adds 'www.' at the beginning of the hostname. If the
  # environment has not associated domains, returns 'localhost'.
  def default_hostname(email_hostname = false)
    if self.domains(true).empty?
      'localhost'
    else
      domain = (self.domains.find_by_is_default(true) || self.domains.find(:first, :order => 'id')).name
      email_hostname ? domain : (force_www ? ('www.' + domain) : domain)
    end
  end

  def top_url(ssl = false)
    protocol = (ssl ? 'https' : 'http')
    result = "#{protocol}://#{default_hostname}"
    if Noosfero.url_options.has_key?(:port)
      result << ':' << Noosfero.url_options[:port].to_s
    end
    result
  end

  def enable_ssl
    settings[:enable_ssl]
  end

  def enable_ssl=(value)
    settings[:enable_ssl] = value
  end

  def to_s
    self.name || '?'
  end

  has_many :articles, :through => :profiles
  def recent_documents(limit = 10)
    self.articles.recent(limit)
  end

  has_many :events, :through => :profiles, :source => :articles, :class_name => 'Event' 

  has_many :tags, :through => :articles

  def tag_counts
    options = Article.find_options_for_tag_counts.merge(:conditions => ['profiles.environment_id = ?', self.id])
    options[:joins] = options[:joins] + ' LEFT OUTER JOIN profiles on profiles.id = articles.profile_id'
    Tag.find(:all, options).inject({}) do |memo,tag|
      memo[tag.name] = tag.count
      memo
    end
  end

  def theme
    self[:theme] || 'default'
  end

  def themes
    if settings[:themes]
      Theme.system_themes.select { |theme| settings[:themes].include?(theme.id) }
    else
      []
    end
  end

  def themes=(values)
    settings[:themes] = values.map(&:id)
  end

  def icon_theme
    settings[:icon_theme] || 'default'
  end
  def icon_theme=(theme)
    settings[:icon_theme] = theme
  end

  def layout_template
    settings[:layout_template] || 'default'
  end

  def layout_template=(value)
    settings[:layout_template] = value
  end

  def community_template
    Community.find_by_id settings[:community_template_id]
  end

  def community_template=(value)
    settings[:community_template_id] = value.id
  end
 
  def person_template
    Person.find_by_id settings[:person_template_id]
  end

  def person_template=(value)
    settings[:person_template_id] = value.id
  end

  def enterprise_template
    Enterprise.find_by_id settings[:enterprise_template_id]
  end

  def enterprise_template=(value)
    settings[:enterprise_template_id] = value.id
  end

  def inactive_enterprise_template
    Enterprise.find_by_id settings[:inactive_enterprise_template_id]
  end

  def inactive_enterprise_template=(value)
    settings[:inactive_enterprise_template_id] = value.id
  end

  def replace_enterprise_template_when_enable
    settings[:replace_enterprise_template_when_enable] || false
  end

  def replace_enterprise_template_when_enable=(value)
    settings[:replace_enterprise_template_when_enable] = value
  end

  def portal_community
    Community[settings[:portal_community_identifier]]
  end

  def portal_community=(value)
    settings[:portal_community_identifier] = value.identifier
  end

  def is_portal_community?(profile)
    portal_community == profile
  end

  def portal_folders
    (settings[:portal_folders] || []).map{|fid| portal_community.articles.find(fid) }
  end

  def portal_folders=(folders)
    settings[:portal_folders] = folders ? folders.map(&:id) : nil
  end

  def news_amount_by_folder
    (settings[:news_amount_by_folder] || 4)
  end

  def news_amount_by_folder=(amount)
    settings[:news_amount_by_folder] = amount.to_i
  end

  def help_message_to_add_enterprise
    self.settings['help_message_to_add_enterprise'] || ''
  end

  def help_message_to_add_enterprise=(value)
    self.settings['help_message_to_add_enterprise'] = value
  end

  def tip_message_enterprise_activation_question
    self.settings['tip_message_enterprise_activation_question'] || ''
  end

  def tip_message_enterprise_activation_question=(value)
    self.settings['tip_message_enterprise_activation_question'] = value
  end

  def portal_news_cache_key
    "home-page-news-#{id}_#{portal_community.name}"
  end

  after_create :create_templates

  def create_templates
    pre = self.name.to_slug + '_'
    ent_id = Enterprise.create!(:name => 'Enterprise template', :identifier => pre + 'enterprise_template', :environment => self, :public_profile => false).id
    com_id = Community.create!(:name => 'Community template', :identifier => pre + 'community_template', :environment => self, :public_profile => false).id
    pass = Digest::MD5.hexdigest rand.to_s
    user = User.create!(:login => (pre + 'person_template'), :email => (pre + 'template@template.noo'), :password => pass, :password_confirmation => pass, :environment => self).person
    user.public_profile = false
    user.save!
    usr_id = user.id
    self.settings[:enterprise_template_id] = ent_id
    self.settings[:community_template_id] = com_id
    self.settings[:person_template_id] = usr_id
    self.save!
  end

end
