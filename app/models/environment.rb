# A Environment is like a website to be hosted in the platform. It may
# contain multiple Profile's and can be identified by several different
# domains.
class Environment < ActiveRecord::Base

  has_many :users

  self.partial_updates = false

  has_many :tasks, :dependent => :destroy, :as => 'target'

  PERMISSIONS['Environment'] = {
    'view_environment_admin_panel' => N_('View environment admin panel'),
    'edit_environment_features' => N_('Edit environment features'),
    'edit_environment_design' => N_('Edit environment design'),
    'manage_environment_categories' => N_('Manage environment categories'),
    'manage_environment_roles' => N_('Manage environment roles'),
    'manage_environment_validators' => N_('Manage environment validators'),
    'manage_environment_users' => N_('Manage environment users'),
  }

  module Roles
    def self.admin(env_id)
      Role.find_by_key_and_environment_id('environment_administrator', env_id)
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
        'perform_task'
      ]
    )
  end

  def add_admin(user)
    self.affiliate(user, Environment::Roles.admin(self.id))
  end

  def admins
    Person.members_of(self).all(:conditions => ['role_assignments.role_id = ?', Environment::Roles.admin(self).id])
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
      'disable_products_for_enterprises' => __('Disable products for enterprises'),
      'disable_categories' => _('Disable categories'),
      'disable_cms' => _('Disable CMS'),
      'disable_header_and_footer' => _('Disable header/footer editing by users'),
      'disable_gender_icon' => _('Disable gender icon'),
      'disable_categories_menu' => _('Disable the categories menu'),
      'disable_select_city_for_contact' => _('Disable state/city select for contact form'),
      'disable_contact_person' => _('Disable contact for people'),
      'disable_contact_community' => _('Disable contact for groups/communities'),
      'enterprise_registration' => __('Enterprise registration'),

      'enterprise_activation' => __('Enable activation of enterprises'),
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
      'enterprises_are_disabled_when_created' => __('Enterprises are disabled when created'),
      'show_balloon_with_profile_links_when_clicked' => _('Show a balloon with profile links when a profile image is clicked'),
      'xmpp_chat' => _('XMPP/Jabber based chat'),
      'show_zoom_button_on_article_images' => _('Show a zoom link on all article images')
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
    env.boxes[2].blocks << CommunitiesBlock.new(:limit => 6)
    env.boxes[2].blocks << PeopleBlock.new(:limit => 6)
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

  has_many :product_categories, :conditions => { :type => 'ProductCategory'}
  has_many :regions

  has_many :roles

  has_many :qualifiers
  has_many :certifiers

  has_many :mailings, :class_name => 'EnvironmentMailing', :foreign_key => :source_id, :as => 'source'

  acts_as_accessible

  has_many :units, :order => 'position'
  has_many :production_costs, :as => :owner

  def superior_intances
    [self, nil]
  end
  # #################################################
  # Attributes
  # #################################################

  # store the Environment settings as YAML-serialized Hash.
  acts_as_having_settings :field => :settings

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

  settings_items :activation_blocked_text, :type => String
  settings_items :message_for_disabled_enterprise, :type => String
  settings_items :location, :type => String
  settings_items :layout_template, :type => String, :default => 'default'
  settings_items :homepage, :type => String
  settings_items :description, :type => String, :default => '<div style="text-align: center"><a href="http://noosfero.org/"><img src="/images/noosfero-network.png" alt="Noosfero"/></a></div>'
  settings_items :enable_ssl
  settings_items :local_docs, :type => Array, :default => []
  settings_items :news_amount_by_folder, :type => Integer, :default => 4
  settings_items :help_message_to_add_enterprise, :type => String, :default => ''
  settings_items :tip_message_enterprise_activation_question, :type => String, :default => ''

  settings_items :currency_unit, :type => String, :default => '$'
  settings_items :currency_separator, :type => String, :default => '.'
  settings_items :currency_delimiter, :type => String, :default => ','

  settings_items :trusted_sites_for_iframe, :type => Array, :default => ['itheora.org', 'tv.softwarelivre.org', 'stream.softwarelivre.org', 'www.youtube.com']

  settings_items :enabled_plugins, :type => Array, :default => []

  def news_amount_by_folder=(amount)
    settings[:news_amount_by_folder] = amount.to_i
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

  def enabled_features
    features = self.class.available_features
    features.delete_if{ |k, v| !self.enabled?(k) }
  end

  before_create :enable_default_features
  def enable_default_features
    %w(
      disable_asset_products
      disable_gender_icon
      disable_products_for_enterprises
      disable_select_city_for_contact
      enterprise_registration
      media_panel
      organizations_are_moderated_by_default
      show_balloon_with_profile_links_when_clicked
      use_portal_community
    ).each do |feature|
      enable(feature)
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

  # #################################################
  # Validations
  # #################################################

  # <tt>name</tt> is mandatory
  validates_presence_of :name

  # only one environment can be the default one
  validates_uniqueness_of :is_default, :if => (lambda do |environment| environment.is_default? end), :message => N_('Only one Virtual Community can be the default one')

  validates_format_of :contact_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |record| ! record.contact_email.blank? })

  xss_terminate :only => [ :message_for_disabled_enterprise ], :with => 'white_list', :on => 'validation'

  validates_presence_of :theme

  include WhiteListFilter
  filter_iframes :message_for_disabled_enterprise, :whitelist => lambda { trusted_sites_for_iframe }

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
    (settings[:portal_folders] || []).map{|fid| portal_community.articles.find(:first, :conditions => { :id => fid }) }.compact
  end

  def portal_folders=(folders)
    settings[:portal_folders] = folders ? folders.map(&:id) : nil
  end

  def portal_news_cache_key
    "home-page-news/#{cache_key}"
  end

  def notification_emails
    [contact_email.blank? ? nil : contact_email].compact + admins.map(&:email)
  end

  after_create :create_templates

  def create_templates
    pre = self.name.to_slug + '_'
    ent_id = Enterprise.create!(:name => 'Enterprise template', :identifier => pre + 'enterprise_template', :environment => self, :visible => false).id
    com_id = Community.create!(:name => 'Community template', :identifier => pre + 'community_template', :environment => self, :visible => false).id
    pass = Digest::MD5.hexdigest rand.to_s
    user = User.create!(:login => (pre + 'person_template'), :email => (pre + 'template@template.noo'), :password => pass, :password_confirmation => pass, :environment => self).person
    user.visible = false
    user.save!
    usr_id = user.id
    self.settings[:enterprise_template_id] = ent_id
    self.settings[:community_template_id] = com_id
    self.settings[:person_template_id] = usr_id
    self.save!
  end

  after_destroy :destroy_templates
  def destroy_templates
    [enterprise_template, community_template, person_template].compact.each do |template|
      template.destroy
    end
  end

  def highlighted_products_with_image(options = {})
    Product.find(:all, {:conditions => {:highlighted => true, :enterprise_id => self.enterprises.find(:all, :select => :id) }, :joins => :image}.merge(options))
  end

  settings_items :home_cache_in_minutes, :type => :integer, :default => 5
  settings_items :general_cache_in_minutes, :type => :integer, :default => 15
  settings_items :profile_cache_in_minutes, :type => :integer, :default => 15

  def image_galleries
    portal_community ? portal_community.image_galleries : []
  end

end

