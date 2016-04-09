# A Environment is like a website to be hosted in the platform. It may
# contain multiple Profile's and can be identified by several different
# domains.
class Environment < ActiveRecord::Base

  attr_accessible :name, :is_default, :signup_welcome_text_subject,
                  :signup_welcome_text_body, :terms_of_use,
                  :message_for_disabled_enterprise, :news_amount_by_folder,
                  :default_language, :languages, :description,
                  :organization_approval_method, :enabled_plugins,
                  :enabled_features, :redirection_after_login,
                  :redirection_after_signup, :contact_email, :theme,
                  :reports_lower_bound, :noreply_email,
                  :signup_welcome_screen_body, :members_whitelist_enabled,
                  :members_whitelist, :highlighted_news_amount,
                  :portal_news_amount, :date_format, :signup_intro,
                  :enable_feed_proxy, :http_feed_proxy, :https_feed_proxy,
                  :disable_feed_ssl

  has_many :users

  # allow roles use
  def self.dangerous_attribute_method? name
    false
  end

  has_many :tasks, :dependent => :destroy, :as => 'target'
  has_many :search_terms, :as => :context
  has_many :custom_fields, :dependent => :destroy
  has_many :email_templates, :foreign_key => :owner_id

  IDENTIFY_SCRIPTS = /(php[0-9s]?|[sp]htm[l]?|pl|py|cgi|rb)/

  validates_inclusion_of :date_format,
                         :in => [ 'numbers_with_year', 'numbers',
                                  'month_name_with_year', 'month_name',
                                  'past_time'],
                         :if => :date_format

  def self.verify_filename(filename)
    filename += '.txt' if File.extname(filename) =~ IDENTIFY_SCRIPTS
    filename
  end

  NUMBER_OF_BOXES = 4

  PERMISSIONS['Environment'] = {
    'view_environment_admin_panel' => N_('View environment admin panel'),
    'edit_environment_features' => N_('Edit environment features'),
    'edit_environment_design' => N_('Edit environment design'),
    'manage_environment_categories' => N_('Manage environment categories'),
    'manage_environment_roles' => N_('Manage environment roles'),
    'manage_environment_validators' => N_('Manage environment validators'),
    'manage_environment_users' => N_('Manage environment users'),
    'manage_environment_organizations' => N_('Manage environment organizations'),
    'manage_environment_templates' => N_('Manage environment templates'),
    'manage_environment_licenses' => N_('Manage environment licenses'),
    'manage_environment_trusted_sites' => N_('Manage environment trusted sites'),
    'edit_appearance'      => N_('Edit appearance'),
    'edit_raw_html_block'      => N_('Edit Raw HTML block'),
    'manage_email_templates' => N_('Manage Email Templates'),
  }

  module Roles
    def self.admin(env_id)
      Role.find_by(key: 'environment_administrator', environment_id: env_id)
    end
  end

  after_create :create_roles
  def create_roles
    Role.create!(
      :key => 'environment_administrator',
      :name => N_('Environment Administrator'),
      :environment => self,
      :permissions => PERMISSIONS[Environment.name].keys + PERMISSIONS[Profile.name].keys
    )
    Role.create!(
      :key => 'profile_admin',
      :name => N_('Profile Administrator'),
      :environment => self,
      :permissions => PERMISSIONS[Profile.name].keys
    )
    # members for enterprises, communities etc
    Role.create!(
      :key => "profile_member",
      :name => N_('Member'),
      :environment => self,
      :permissions => [
        'invite_members',
      ]
    )
    # moderators for enterprises, communities etc
    Role.create!(
      :key => 'profile_moderator',
      :name => N_('Moderator'),
      :environment => self,
      :permissions => [
        'manage_memberships',
        'edit_profile_design',
        'manage_products',
        'manage_friends',
        'perform_task',
        'view_tasks'
      ]
    )
  end

  def add_admin(user)
    self.affiliate(user, Environment::Roles.admin(self.id))
  end

  def remove_admin(user)
    self.disaffiliate(user, Environment::Roles.admin(self.id))
  end

  def admins
    admin_role = Environment::Roles.admin(self)
    return [] if admin_role.blank?
    Person.members_of(self).where 'role_assignments.role_id = ?', admin_role.id
  end

  # returns the available features for a Environment, in the form of a
  # hash, with pairs in the form <tt>'feature_name' => 'Feature name'</tt>.
  def self.available_features
    {
      'disable_asset_articles' => _('Disable search for articles '),
      'disable_asset_enterprises' => _('Disable search for enterprises'),
      'disable_asset_people' => _('Disable search for people'),
      'disable_asset_communities' => _('Disable search for communities'),
      'disable_asset_products' => _('Disable search for products'),
      'disable_asset_events' => _('Disable search for events'),
      'disable_categories' => _('Disable categories'),
      'disable_header_and_footer' => _('Disable header/footer editing by users'),
      'disable_gender_icon' => _('Disable gender icon'),
      'disable_categories_menu' => _('Disable the categories menu'),
      'disable_select_city_for_contact' => _('Disable state/city select for contact form'),
      'disable_contact_person' => _('Disable contact for people'),
      'disable_contact_community' => _('Disable contact for groups/communities'),
      'forbid_destroy_profile' => _('Forbid users of removing profiles'),

      'products_for_enterprises' => _('Enable products for enterprises'),
      'enterprise_registration' => _('Enterprise registration'),
      'enterprise_activation' => _('Enable activation of enterprises'),
      'enterprises_are_disabled_when_created' => _('Enterprises are disabled when created'),
      'enterprises_are_validated_when_created' => _('Enterprises are validated when created'),

      'media_panel' => _('Media panel in WYSIWYG editor'),
      'select_preferred_domain' => _('Select preferred domains per profile'),
      'use_portal_community' => _('Use the portal as news source for front page'),
      'user_themes' => _('Allow users to create their own themes'),
      'search_in_home' => _("Display search form in home page"),

      'cant_change_homepage' => _("Don't allow users to change which article to use as homepage"),
      'display_header_footer_explanation' => _("Display explanation about header and footer"),
      'articles_dont_accept_comments_by_default' => _("Articles don't accept comments by default"),
      'organizations_are_moderated_by_default' => _("Organizations have moderated publication by default"),
      'enable_organization_url_change' => _("Allow organizations to change their URL"),
      'admin_must_approve_new_communities' => _("Admin must approve creation of communities"),
      'admin_must_approve_new_users' => _("Admin must approve registration of new users"),
      'show_balloon_with_profile_links_when_clicked' => _('Show a balloon with profile links when a profile image is clicked'),
      'xmpp_chat' => _('XMPP/Jabber based chat'),
      'show_zoom_button_on_article_images' => _('Show a zoom link on all article images'),
      'captcha_for_logged_users' => _('Ask captcha when a logged user comments too'),
      'skip_new_user_email_confirmation' => _('Skip e-mail confirmation for new users'),
      'send_welcome_email_to_new_users' => _('Send welcome e-mail to new users'),
      'allow_change_of_redirection_after_login' => _('Allow users to set the page to redirect after login'),
      'display_my_communities_on_user_menu' => _('Display on menu the list of communities the user can manage'),
      'display_my_enterprises_on_user_menu' => _('Display on menu the list of enterprises the user can manage'),
      'restrict_to_members' => _('Show content only to members'),

      'enable_appearance' => _('Enable appearance editing by users'),
    }
  end

  def self.login_redirection_options
    {
      'keep_on_same_page' => _('Stays on the same page the user was before login.'),
      'site_homepage' => _('Redirects the user to the environment homepage.'),
      'user_profile_page' => _('Redirects the user to his profile page.'),
      'user_homepage' => _('Redirects the user to his homepage.'),
      'user_control_panel' => _('Redirects the user to his control panel.'),
      'custom_url' => _('Specify the URL to redirect to:'),
    }
  end
  validates_inclusion_of :redirection_after_login, :in => Environment.login_redirection_options.keys, :allow_nil => true

  def self.signup_redirection_options
    {
      'keep_on_same_page' => _('Stays on the same page the user was before signup.'),
      'site_homepage' => _('Redirects the user to the environment homepage.'),
      'user_profile_page' => _('Redirects the user to his profile page.'),
      'user_homepage' => _('Redirects the user to his homepage.'),
      'user_control_panel' => _('Redirects the user to his control panel.'),
      'welcome_page' => _('Redirects the user to the environment welcome page.')
    }
  end
  validates_inclusion_of :redirection_after_signup, :in => Environment.signup_redirection_options.keys, :allow_nil => true


  # #################################################
  # Relationships and applied behaviour
  # #################################################

  acts_as_having_boxes

  after_create do |env|
    NUMBER_OF_BOXES.times do
      env.boxes << Box.new
    end

    # main area
    env.boxes[0].blocks << MainBlock.new

    # "left" area
    env.boxes[1].blocks << LoginBlock.new
    env.boxes[1].blocks << RecentDocumentsBlock.new

    # "right" area
    env.boxes[2].blocks << CommunitiesBlock.new(:limit => 6)
  end

  # One Environment can be reached by many domains
  has_many :domains, :as => :owner
  has_many :profiles, :dependent => :destroy

  has_many :organizations
  has_many :enterprises
  has_many :products, :through => :enterprises
  has_many :people
  has_many :communities
  has_many :licenses

  has_many :categories
  has_many :display_categories, -> {
    order('display_color').where('display_color is not null and parent_id is null')
  }, class_name: 'Category'

  has_many :product_categories, -> { where type: 'ProductCategory'}
  has_many :regions
  has_many :states
  has_many :cities

  has_many :roles, :dependent => :destroy

  has_many :qualifiers
  has_many :certifiers

  has_many :mailings, :class_name => 'EnvironmentMailing', :foreign_key => :source_id, :as => 'source'

  acts_as_accessible

  has_many :units, -> { order 'position' }
  has_many :production_costs, :as => :owner

  def superior_intances
    [self, nil]
  end
  # #################################################
  # Attributes
  # #################################################

  # store the Environment settings as YAML-serialized Hash.
  acts_as_having_settings :field => :settings

  # introduce and explain to users something about the signup
  settings_items :signup_intro, :type => String

  # the environment's terms of use: every user must accept them before registering.
  settings_items :terms_of_use, :type => String

  # the environment's terms of enterprise use: every enterprise member must accept them before
  # registering or activating enterprises.
  settings_items :terms_of_enterprise_use, :type => String

  # returns the approval method used for this environment. Possible values are:
  #
  # Defaults to <tt>:admim</tt>.
  settings_items :organization_approval_method, :type => Symbol, :default => :admin

  # Whether this environment should force having 'www.' in its domain name or
  # not. Defauls to false.
  #
  # Sets the value of #force_www. <tt>value</tt> must be a boolean.
  #
  # See also #default_hostname
  settings_items :force_www, :default => false

  settings_items :message_for_friend_invitation, :type => String
  def message_for_friend_invitation
    settings[:message_for_member_invitation] || InviteFriend.mail_template
  end

  settings_items :message_for_member_invitation, :type => String
  def message_for_member_invitation
    settings[:message_for_member_invitation] || InviteMember.mail_template
  end

  settings_items :min_signup_delay, :type => Integer, :default => 3 #seconds
  settings_items :activation_blocked_text, :type => String
  settings_items :message_for_disabled_enterprise, :type => String,
                 :default => _('This enterprise needs to be enabled.')

  settings_items :contact_phone, type: String
  settings_items :address, type: String
  settings_items :city, type: String
  settings_items :state, type: String
  settings_items :country_name, type: String
  settings_items :lat, type: Float
  settings_items :lng, type: Float
  settings_items :postal_code, type: String
  settings_items :location, type: String

  alias_method :zip_code=, :postal_code
  alias_method :zip_code, :postal_code

  settings_items :layout_template, :type => String, :default => 'default'
  settings_items :homepage, :type => String
  settings_items :description, :type => String, :default => '<div style="text-align: center"><a href="http://noosfero.org/"><img src="/images/noosfero-network.png" alt="Noosfero"/></a></div>'
  settings_items :local_docs, :type => Array, :default => []
  settings_items :news_amount_by_folder, :type => Integer, :default => 4
  settings_items :highlighted_news_amount, :type => Integer, :default => 2
  settings_items :portal_news_amount, :type => Integer, :default => 5
  settings_items :help_message_to_add_enterprise, :type => String, :default => ''
  settings_items :tip_message_enterprise_activation_question, :type => String, :default => ''

  settings_items :currency_iso_unit, :type => String, :default => 'USD'
  settings_items :currency_unit, :type => String, :default => '$'
  settings_items :currency_separator, :type => String, :default => '.'
  settings_items :currency_delimiter, :type => String, :default => ','

  settings_items :trusted_sites_for_iframe, :type => Array, :default => %w[
    developer.myspace.com
    itheora.org
    maps.google.com
    platform.twitter.com
    player.vimeo.com
    stream.softwarelivre.org
    tv.softwarelivre.org
    www.facebook.com
    www.flickr.com
    www.gmodules.com
    www.youtube.com
    openstreetmap.org
  ] + ('a' .. 'z').map{|i| "#{i}.yimg.com"}

  settings_items :enabled_plugins, :type => Array, :default => Noosfero::Plugin.available_plugin_names

  settings_items :search_hints, :type => Hash, :default => {}

  # Set to return http forbidden to host not on the allow origin list bellow
  settings_items :restrict_to_access_control_origins, :default => false
  # Set this according to http://www.w3.org/TR/cors/. Headers are set at every response
  # For multiple domains acts as suggested in http://stackoverflow.com/questions/1653308/access-control-allow-origin-multiple-origin-domains
  settings_items :access_control_allow_origin, :type => Array, :default => []
  settings_items :access_control_allow_methods, :type => String

  settings_items :signup_welcome_screen_body, :type => String

  def has_custom_welcome_screen?
    settings[:signup_welcome_screen_body].present?
  end

  settings_items :members_whitelist_enabled, :type => :boolean, :default => false
  settings_items :members_whitelist, :type => Array, :default => []

  def in_whitelist?(person)
    !members_whitelist_enabled || members_whitelist.include?(person.id)
  end

  def members_whitelist=(members)
    settings[:members_whitelist] = members.split(',').map(&:to_i)
  end

  def news_amount_by_folder=(amount)
    settings[:news_amount_by_folder] = amount.to_i
  end

  # Enables a feature identified by its name
  def enable(feature, must_save=true)
    self.settings["#{feature}_enabled".to_sym] = true
    self.save! if must_save
  end

  def enable_plugin(plugin)
    self.enabled_plugins += [plugin.to_s]
    self.enabled_plugins.uniq!
    self.save!
  end

  def enable_all_plugins
    Noosfero::Plugin.available_plugin_names.each do |plugin|
      plugin_name = plugin.to_s + "Plugin"
      unless self.enabled_plugins.include?(plugin_name)
        self.enabled_plugins += [plugin_name]
      end
    end
    self.save!
  end

  # Disables a feature identified by its name
  def disable(feature, must_save=true)
    self.settings["#{feature}_enabled".to_sym] = false
    self.save! if must_save
  end

  def disable_plugin(plugin)
    self.enabled_plugins.delete(plugin.to_s)
    self.save!
  end

  # Tells if a feature, identified by its name, is enabled
  def enabled?(feature)
    self.settings["#{feature}_enabled".to_sym] == true
  end
  def disabled?(feature)
    !self.enabled?(feature)
  end

  def plugin_enabled?(plugin)
    enabled_plugins.include?(plugin.to_s)
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

  def enabled_features
    features = self.class.available_features
    features.delete_if{ |k, v| !self.enabled?(k) }
  end

  DEFAULT_FEATURES = %w(
    disable_asset_products
    disable_gender_icon
    products_for_enterprises
    disable_select_city_for_contact
    enterprise_registration
    media_panel
    organizations_are_moderated_by_default
    show_balloon_with_profile_links_when_clicked
    show_zoom_button_on_article_images
    use_portal_community
    enable_appearance
  )

  before_create :enable_default_features
  def enable_default_features
    DEFAULT_FEATURES.each do |feature|
      enable(feature, false)
    end
  end

  # returns <tt>true</tt> if this Environment has terms of use to be
  # accepted by users before registration.
  def has_terms_of_use?
    ! self.terms_of_use.blank?
  end

  # returns <tt>true</tt> if this Environment has terms of enterprise use to be
  # accepted by users before registration or activation of enterprises.
  def has_terms_of_enterprise_use?
    ! self.terms_of_enterprise_use.blank?
  end

  # Sets the organization_approval_method. Only accepts the following values:
  #
  # * <tt>:admin</tt>: organization registration must be approved by the
  #   environment administrator.
  # * <tt>:region</tt>: organization registering must be approved by some other
  #   organization asssigned as validator to the Region the new organization
  #   belongs to.
  # * <tt>:none</tt>: organization registration is approved by default.
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
      none
    ].map(&:to_sym)
    raise ArgumentError unless accepted_values.include?(actual_value)

    self.settings[:organization_approval_method] = actual_value
  end

  def custom_person_fields
    self.settings[:custom_person_fields].nil? ? {} : self.settings[:custom_person_fields]
  end

  def custom_person_fields=(values)
    if values['schooling'] && values['schooling']['active'] == 'true'
      schooling_status = values['schooling']
    end

    self.settings[:custom_person_fields] = values.delete_if { |key, value| ! Person.fields.include?(key)}
    self.settings[:custom_person_fields].each_pair do |key, value|
      if value['required'] == 'true'
        self.settings[:custom_person_fields][key]['active'] = 'true'
        self.settings[:custom_person_fields][key]['signup'] = 'true'
      end
      if value['signup'] == 'true'
        self.settings[:custom_person_fields][key]['active'] = 'true'
      end
    end

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

  def invitation_mail_template(profile)
    if profile.person?
      message_for_friend_invitation
    else
      message_for_member_invitation
    end
  end

  def custom_enterprise_fields
    self.settings[:custom_enterprise_fields].nil? ? {} : self.settings[:custom_enterprise_fields]
  end

  def custom_enterprise_fields=(values)
    self.settings[:custom_enterprise_fields] = values.delete_if { |key, value| ! Enterprise.fields.include?(key)}
    self.settings[:custom_enterprise_fields].each_pair do |key, value|
      if value['required'] == 'true'
        self.settings[:custom_enterprise_fields][key]['active'] = 'true'
        self.settings[:custom_enterprise_fields][key]['signup'] = 'true'
      end
      if value['signup'] == 'true'
        self.settings[:custom_enterprise_fields][key]['active'] = 'true'
      end
    end
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

  def signup_enterprise_fields
    signup_fields = []
    active_enterprise_fields.each do |field|
      signup_fields << field if custom_enterprise_fields[field]['signup'] == 'true'
    end
    signup_fields
  end

  def custom_community_fields
    self.settings[:custom_community_fields].nil? ? {} : self.settings[:custom_community_fields]
  end
  def custom_community_fields=(values)
    self.settings[:custom_community_fields] = values.delete_if { |key, value| ! Community.fields.include?(key) }
    self.settings[:custom_community_fields].each_pair do |key, value|
      if value['required'] == 'true'
        self.settings[:custom_community_fields][key]['active'] = 'true'
        self.settings[:custom_community_fields][key]['signup'] = 'true'
      end
      if value['signup'] == 'true'
        self.settings[:custom_community_fields][key]['active'] = 'true'
      end
    end
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

  def signup_community_fields
    signup_fields = []
    active_community_fields.each do |field|
      signup_fields << field if custom_community_fields[field]['signup'] == 'true'
    end
    signup_fields
  end

  serialize :signup_welcome_text, Hash
  def signup_welcome_text
    self[:signup_welcome_text] ||= {}
  end

  def signup_welcome_text_subject
    self.signup_welcome_text[:subject]
  end

  def signup_welcome_text_subject=(subject)
    self.signup_welcome_text[:subject] = subject
  end

  def signup_welcome_text_body
    self.signup_welcome_text[:body]
  end

  def signup_welcome_text_body=(body)
    self.signup_welcome_text[:body] = body
  end

  def has_signup_welcome_text?
    signup_welcome_text && !signup_welcome_text_body.blank?
  end

  # #################################################
  # Validations
  # #################################################

  # <tt>name</tt> is mandatory
  validates_presence_of :name

  # only one environment can be the default one
  validates_uniqueness_of :is_default, :if => (lambda do |environment| environment.is_default? end), :message => N_('Only one Virtual Community can be the default one')

  validates_format_of :contact_email, :noreply_email, :with => Noosfero::Constants::EMAIL_FORMAT, :allow_blank => true

  xss_terminate :only => [ :message_for_disabled_enterprise ], :with => 'white_list', :on => 'validation'

  validates_presence_of :theme
  validates_numericality_of :reports_lower_bound, :allow_nil => false, :only_integer => true, :greater_than_or_equal_to => 0

  include WhiteListFilter
  filter_iframes :message_for_disabled_enterprise
  def iframe_whitelist
    trusted_sites_for_iframe
  end

  # #################################################
  # Business logic in general
  # #################################################

  # the default Environment.
  def self.default
    self.where('is_default = ?', true).first
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
    domain = 'localhost'
    unless self.domains(true).empty?
      domain = (self.domains.find_by(is_default: true) || self.domains.order(:id).first).name
      domain = email_hostname ? domain : (force_www ? ('www.' + domain) : domain)
    end
    domain
  end

  def admin_url
    { :controller => 'admin_panel', :action => 'index' }
  end

  def top_url(scheme = 'http')
    url = scheme + '://'
    url << (Noosfero.url_options.key?(:host) ? Noosfero.url_options[:host] : default_hostname)
    url << ':' << Noosfero.url_options[:port].to_s if Noosfero.url_options.key?(:port)
    url << Noosfero.root('')
    url
  end

  def to_s
    self.name || '?'
  end

  has_many :articles, :through => :profiles
  def recent_documents(limit = 10, options = {}, pagination = true)
    self.articles.recent(limit, options, pagination)
  end

  has_many :events, :through => :profiles, :source => :articles, :class_name => 'Event'

  has_many :tags, :through => :articles

  def tag_counts
    articles.tag_counts.inject({}) do |memo,tag|
      memo[tag.name] = tag.count
      memo
    end
  end

  def themes
    if settings[:themes]
      Theme.system_themes.select { |theme| settings[:themes].include?(theme.id) }
    else
      []
    end
  end

  def themes=(values)
    settings[:themes] = values
  end

  def add_themes(values)
    if settings[:themes].nil?
      self.themes = values
    else
      settings[:themes] += values
    end
  end

  def update_theme(theme)
    self.theme = theme
    self.save!
  end

  def update_layout_template(template)
    self.layout_template = template
    self.save!
  end

  before_create do |env|
    env.settings[:themes] ||= %w[
      aluminium
      butter
      chameleon
      chocolate
      noosfero
      orange
      plum
      scarletred
      skyblue
    ]
  end

  def is_default_template?(template)
    is_default = template == community_default_template
    is_default = is_default || template == person_default_template
    is_default = is_default || template == enterprise_default_template
    is_default
  end

  def community_templates
    self.communities.templates
  end

  def community_default_template
    template = Community.find_by id: settings[:community_template_id]
    template if template && template.is_template?
  end

  def community_default_template=(value)
    settings[:community_template_id] = value.kind_of?(Community) ? value.id : value
  end

  def person_templates
    self.people.templates
  end

  def person_default_template
    template = Person.find_by id: settings[:person_template_id]
    template if template && template.is_template?
  end

  def person_default_template=(value)
    settings[:person_template_id] = value.kind_of?(Person) ? value.id : value
  end

  def enterprise_templates
    self.enterprises.templates
  end

  def enterprise_default_template
    template = Enterprise.find_by id: settings[:enterprise_template_id]
    template if template && template.is_template?
  end

  def enterprise_default_template=(value)
    settings[:enterprise_template_id] = value.kind_of?(Enterprise) ? value.id : value
  end

  def inactive_enterprise_template
    template = Enterprise.find_by id: settings[:inactive_enterprise_template_id]
    template if template && template.is_template
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
    settings[:portal_community_identifier] = value.nil? ? nil : value.identifier
  end

  def unset_portal_community!
    self.portal_community=nil
    self.portal_folders=nil
    self.news_amount_by_folder=nil
    self.disable('use_portal_community')
    self.save
  end

  def is_portal_community?(profile)
    portal_community == profile
  end

  def portal_folders
    (settings[:portal_folders] || []).map{|fid| portal_community.articles.where(id: fid).first }.compact
  end

  def portal_folders=(folders)
    settings[:portal_folders] = folders ? folders.map(&:id) : nil
  end

  def portal_news_cache_key(language='en')
    "home-page-news/#{cache_key}-#{language}"
  end

  def portal_enabled
    portal_community && enabled?('use_portal_community')
  end

  def notification_emails
    [contact_email].select(&:present?) + admins.map(&:email)
  end

  after_create :create_templates

  def create_templates
    prefix = self.name.to_slug + '_'

    enterprise_template = Enterprise.new(
      :name => 'Enterprise template',
      :identifier => prefix + 'enterprise_template'
    )

    inactive_enterprise_template = Enterprise.new(
      :name => 'Inactive Enterprise template',
      :identifier => prefix + 'inactive_enterprise_template'
    )

    community_template = Community.new(
      :name => 'Community template',
      :identifier => prefix + 'community_template'
    )

    [
      enterprise_template,
      inactive_enterprise_template,
      community_template
    ].each do |profile|
      profile.is_template = true
      profile.visible = false
      profile.environment = self
      profile.save!
    end

    pass = Digest::MD5.hexdigest rand.to_s
    user = User.new(:login => (prefix + 'person_template'), :email => (prefix + 'template@template.noo'), :password => pass, :password_confirmation => pass)
    user.environment = self
    user.save!

    person_template = user.person
    person_template.name = "Person template"
    person_template.is_template = true
    person_template.visible = false
    person_template.save!

    self.enterprise_default_template = enterprise_template
    self.inactive_enterprise_template = inactive_enterprise_template
    self.community_default_template = community_template
    self.person_default_template = person_template
    self.save!
  end

  after_create :create_default_licenses
  def create_default_licenses
    [
      { :name => 'CC (by)', :url => 'http://creativecommons.org/licenses/by/3.0/legalcode'},
      { :name => 'CC (by-nd)', :url => 'http://creativecommons.org/licenses/by-nd/3.0/legalcode'},
      { :name => 'CC (by-sa)', :url => 'http://creativecommons.org/licenses/by-sa/3.0/legalcode'},
      { :name => 'CC (by-nc)', :url => 'http://creativecommons.org/licenses/by-nc/3.0/legalcode'},
      { :name => 'CC (by-nc-nd)', :url => 'http://creativecommons.org/licenses/by-nc-nd/3.0/legalcode'},
      { :name => 'CC (by-nc-sa)', :url => 'http://creativecommons.org/licenses/by-nc-sa/3.0/legalcode'},
      { :name => 'Free Art', :url => 'http://artlibre.org/licence/lal/en'},
      { :name => 'GNU FDL', :url => 'http://www.gnu.org/licenses/fdl-1.3.txt'},
    ].each do |data|
      license = License.new(data)
      license.environment = self
      license.save!
    end
  end

  def highlighted_products_with_image(options = {})
    self.products.where(highlighted: true).joins(:image).order('created_at ASC')
  end

  settings_items :home_cache_in_minutes, :type => :integer, :default => 5
  settings_items :general_cache_in_minutes, :type => :integer, :default => 15
  settings_items :profile_cache_in_minutes, :type => :integer, :default => 15

  def image_galleries
    portal_community ? portal_community.image_galleries : []
  end

  serialize :languages

  before_validation do |environment|
    environment.default_language = nil if environment.default_language.blank?
  end

  validate :default_language_available
  validate :languages_available

  def locales
    if languages.present?
      languages.inject({}) {|r, l| r.merge({l => Noosfero.locales[l]})}
    else
      Noosfero.locales
    end
  end

  def default_locale
    default_language || Noosfero.default_locale
  end

  def available_locales
    locales_list = locales.keys
    # move English to the beginning
    if locales_list.include?('en')
      locales_list = ['en'] + (locales_list - ['en']).sort
    end
    locales_list
  end

  def has_license?
    self.licenses.any?
  end

  def to_liquid
    HashWithIndifferentAccess.new :name => name
  end

  private

  def default_language_available
    if default_language.present? && !available_locales.include?(default_language)
      errors.add(:default_language, _('is not available.'))
    end
  end

  def languages_available
    if languages.present?
      languages.each do |language|
        if !Noosfero.available_locales.include?(language)
          errors.add(:languages, _('have unsupported languages.'))
          break
        end
      end
    end
  end
end
