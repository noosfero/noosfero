# A Profile is the representation and web-presence of an individual or an
# organization. Every Profile is attached to its Environment of origin,
# which by default is the one returned by Environment:default.
class Profile < ActiveRecord::Base

  attr_accessible :name, :identifier, :public_profile, :nickname, :custom_footer, :custom_header, :address, :zip_code, :contact_phone, :image_builder, :description, :closed, :template_id, :environment, :lat, :lng, :is_template, :fields_privacy, :preferred_domain_id, :category_ids, :country, :city, :state, :national_region_code, :email, :contact_email, :redirect_l10n

  # use for internationalizable human type names in search facets
  # reimplement on subclasses
  def self.type_name
    _('Profile')
  end

  SEARCHABLE_FIELDS = {
    :name => 10,
    :identifier => 5,
    :nickname => 2,
  }

  SEARCH_FILTERS = %w[
    more_recent
  ]

  SEARCH_DISPLAYS = %w[compact]

  def self.default_search_display
    'compact'
  end

  module Roles
    def self.admin(env_id)
      find_role('admin', env_id)
    end
    def self.member(env_id)
      find_role('member', env_id)
    end
    def self.moderator(env_id)
      find_role('moderator', env_id)
    end
    def self.owner(env_id)
      find_role('owner', env_id)
    end
    def self.editor(env_id)
      find_role('editor', env_id)
    end
    def self.organization_member_roles(env_id)
      all_roles(env_id).select{ |r| r.key.match(/^profile_/) unless r.key.blank? }
    end
    def self.all_roles(env_id)
      Role.all :conditions => { :environment_id => env_id }
    end
    def self.method_missing(m, *args, &block)
      role = find_role(m, args[0])
      return role unless role.nil?
      super
    end
    private
    def self.find_role(name, env_id)
      ::Role.find_by_key_and_environment_id("profile_#{name}", env_id)
    end
  end

  PERMISSIONS['Profile'] = {
    'edit_profile'         => N_('Edit profile'),
    'destroy_profile'      => N_('Destroy profile'),
    'manage_memberships'   => N_('Manage memberships'),
    'post_content'         => N_('Manage content'), # changed only presentation name to keep already given permissions
    'edit_profile_design'  => N_('Edit profile design'),
    'manage_products'      => N_('Manage products'),
    'manage_friends'       => N_('Manage friends'),
    'validate_enterprise'  => N_('Validate enterprise'),
    'perform_task'         => N_('Perform task'),
    'moderate_comments'    => N_('Moderate comments'),
    'edit_appearance'      => N_('Edit appearance'),
    'view_private_content' => N_('View private content'),
    'publish_content'      => N_('Publish content'),
    'invite_members'       => N_('Invite members'),
    'send_mail_to_members' => N_('Send e-Mail to members'),
  }

  acts_as_accessible

  include Noosfero::Plugin::HotSpot

  scope :memberships_of, lambda { |person| { :select => 'DISTINCT profiles.*', :joins => :role_assignments, :conditions => ['role_assignments.accessor_type = ? AND role_assignments.accessor_id = ?', person.class.base_class.name, person.id ] } }
  #FIXME: these will work only if the subclass is already loaded
  scope :enterprises, lambda { {:conditions => (Enterprise.send(:subclasses).map(&:name) << 'Enterprise').map { |klass| "profiles.type = '#{klass}'"}.join(" OR ")} }
  scope :communities, lambda { {:conditions => (Community.send(:subclasses).map(&:name) << 'Community').map { |klass| "profiles.type = '#{klass}'"}.join(" OR ")} }
  scope :templates, {:conditions => {:is_template => true}}
  scope :no_templates, {:conditions => {:is_template => false}}

  def members
    scopes = plugins.dispatch_scopes(:organization_members, self)
    scopes << Person.members_of(self)
    return scopes.first if scopes.size == 1
    ScopeTool.union *scopes
  end

  def members_by_name
    members.order(:name)
  end

  class << self
    def count_with_distinct(*args)
      options = args.last || {}
      count_without_distinct(:id, {:distinct => true}.merge(options))
    end
    alias_method_chain :count, :distinct
  end

  def members_by_role(role)
    Person.members_of(self).all(:conditions => ['role_assignments.role_id = ?', role.id])
  end

  acts_as_having_boxes

  acts_as_taggable

  def self.qualified_column_names
    Profile.column_names.map{|n| [Profile.table_name, n].join('.')}.join(',')
  end

  scope :visible, :conditions => { :visible => true }
  scope :public, :conditions => { :visible => true, :public_profile => true }

  # Subclasses must override this method
  scope :more_popular

  scope :more_active,  :order => 'activities_count DESC'
  scope :more_recent, :order => "created_at DESC"

  acts_as_trackable :dependent => :destroy

  has_many :action_tracker_notifications, :foreign_key => 'profile_id'
  has_many :tracked_notifications, :through => :action_tracker_notifications, :source => :action_tracker, :order => 'updated_at DESC'
  has_many :scraps_received, :class_name => 'Scrap', :foreign_key => :receiver_id, :order => "updated_at DESC", :dependent => :destroy
  belongs_to :template, :class_name => 'Profile', :foreign_key => 'template_id'

  has_many :comments_received, :class_name => 'Comment', :through => :articles, :source => :comments

  def scraps(scrap=nil)
    scrap = scrap.is_a?(Scrap) ? scrap.id : scrap
    scrap.nil? ? Scrap.all_scraps(self) : Scrap.all_scraps(self).find(scrap)
  end

  acts_as_having_settings :field => :data

  def settings
    data
  end

  settings_items :redirect_l10n, :type => :boolean, :default => false
  settings_items :public_content, :type => :boolean, :default => true
  settings_items :description
  settings_items :fields_privacy, :type => :hash, :default => {}

  validates_length_of :description, :maximum => 550, :allow_nil => true

  # Valid identifiers must match this format.
  IDENTIFIER_FORMAT = /^#{Noosfero.identifier_format}$/

  # These names cannot be used as identifiers for Profiles
  RESERVED_IDENTIFIERS = %w[
  admin
  system
  myprofile
  profile
  cms
  community
  test
  search
  not_found
  cat
  tag
  tags
  environment
  webmaster
  info
  root
  assets
  doc
  chat
  plugin
  site
  ]

  belongs_to :user

  has_many :domains, :as => :owner
  belongs_to :preferred_domain, :class_name => 'Domain', :foreign_key => 'preferred_domain_id'
  belongs_to :environment

  has_many :articles, :dependent => :destroy
  belongs_to :home_page, :class_name => Article.name, :foreign_key => 'home_page_id'

  has_many :files, :class_name => 'UploadedFile'

  acts_as_having_image

  has_many :tasks, :dependent => :destroy, :as => 'target'

  has_many :events, :source => 'articles', :class_name => 'Event', :order => 'start_date'

  def find_in_all_tasks(task_id)
    begin
      Task.to(self).find(task_id)
    rescue
      nil
    end
  end

  has_many :profile_categorizations, :conditions => [ 'categories_profiles.virtual = ?', false ]
  has_many :categories, :through => :profile_categorizations

  has_many :profile_categorizations_including_virtual, :class_name => 'ProfileCategorization'
  has_many :categories_including_virtual, :through => :profile_categorizations_including_virtual, :source => :category

  has_many :abuse_complaints, :foreign_key => 'requestor_id', :dependent => :destroy

  def top_level_categorization
    ret = {}
    self.profile_categorizations.each do |c|
      p = c.category.top_ancestor
      ret[p] = (ret[p] || []) + [c.category]
    end
    ret
  end

  def interests
    categories.select {|item| !item.is_a?(Region)}
  end

  belongs_to :region

  LOCATION_FIELDS = %w[address district city state country_name zip_code]

  def location(separator = ' - ')
    myregion = self.region
    if myregion
      myregion.hierarchy.reverse.first(2).map(&:name).join(separator)
    else
      LOCATION_FIELDS.map {|item| (self.respond_to?(item) && !self.send(item).blank?) ? self.send(item) : nil }.compact.join(separator)
    end
  end

  def geolocation
    unless location.blank?
      location
    else
      if environment.location.blank?
        environment.location = "BRA"
      end
      environment.location
    end
  end

  def country_name
    CountriesHelper::Object.instance.lookup(country) if respond_to?(:country)
  end

  def pending_categorizations
    @pending_categorizations ||= []
  end

  def add_category(c, reload=false)
    if new_record?
      pending_categorizations << c
    else
      ProfileCategorization.add_category_to_profile(c, self)
      self.categories(true)
    end
    self.categories(reload)
  end

  def category_ids=(ids)
    ProfileCategorization.remove_all_for(self)
    ids.uniq.each do |item|
      add_category(Category.find(item)) unless item.to_i.zero?
    end
  end

  after_create :create_pending_categorizations
  def create_pending_categorizations
    pending_categorizations.each do |item|
      ProfileCategorization.add_category_to_profile(item, self)
    end
    pending_categorizations.clear
  end

  def top_level_articles(reload = false)
    if reload
      @top_level_articles = nil
    end
    @top_level_articles ||= Article.top_level_for(self)
  end

  def self.is_available?(identifier, environment)
    !(identifier =~ IDENTIFIER_FORMAT).nil? && !RESERVED_IDENTIFIERS.include?(identifier) && Profile.find(:first, :conditions => ['environment_id = ? and identifier = ?', environment.id, identifier]).nil?
  end

  validates_presence_of :identifier, :name
  validates_format_of :identifier, :with => IDENTIFIER_FORMAT, :if => lambda { |profile| !profile.identifier.blank? }
  validates_exclusion_of :identifier, :in => RESERVED_IDENTIFIERS
  validates_uniqueness_of :identifier, :scope => :environment_id
  validates_length_of :nickname, :maximum => 16, :allow_nil => true
  validate :valid_template

  def valid_template
    if template_id.present? && template && !template.is_template
      errors.add(:template, _('is not a template.'))
    end
  end

  before_create :set_default_environment
  def set_default_environment
    if self.environment.nil?
      self.environment = Environment.default
    end
    true
  end

  # registar callback for creating boxes after the object is created.
  after_create :create_default_set_of_boxes

  # creates the initial set of boxes when the profile is created. Can be
  # overriden for each subclass to create a custom set of boxes for its
  # instances.
  def create_default_set_of_boxes
    if template
      apply_template(template, :copy_articles => false)
    else
      3.times do
        self.boxes << Box.new
      end

      if self.respond_to?(:default_set_of_blocks)
        default_set_of_blocks.each_with_index do |blocks,i|
          blocks.each do |block|
            self.boxes[i].blocks << block
          end
        end
      end
    end

    true
  end

  def copy_blocks_from(profile)
    self.boxes.destroy_all
    profile.boxes.each do |box|
      new_box = Box.new
      new_box.position = box.position
      self.boxes << new_box
      box.blocks.each do |block|
        new_block = block.class.new(:title => block[:title])
        new_block.settings = block.settings
        new_block.position = block.position
        self.boxes[-1].blocks << new_block
      end
    end
  end

  # this method should be overwritten to provide the correct template
  def default_template
    nil
  end

  def template_with_default
    template_without_default || default_template
  end
  alias_method_chain :template, :default

  def apply_template(template, options = {:copy_articles => true})
    copy_blocks_from(template)
    copy_articles_from(template) if options[:copy_articles]
    self.apply_type_specific_template(template)

    # copy interesting attributes
    self.layout_template = template.layout_template
    self.theme = template.theme
    self.custom_footer = template[:custom_footer]
    self.custom_header = template[:custom_header]
    self.public_profile = template.public_profile

    # flush
    self.save(:validate => false)
  end

  def apply_type_specific_template(template)
  end

  xss_terminate :only => [ :name, :nickname, :address, :contact_phone, :description ], :on => 'validation'
  xss_terminate :only => [ :custom_footer, :custom_header ], :with => 'white_list', :on => 'validation'

  include WhiteListFilter
  filter_iframes :custom_header, :custom_footer
  def iframe_whitelist
    environment && environment.trusted_sites_for_iframe
  end

  # returns the contact email for this profile.
  #
  # Subclasses may -- and should -- override this method.
  def contact_email
    raise NotImplementedError
  end

  # This method must return a list of e-mail adresses to which notification messages must be sent.
  # The implementation in this class just delegates to +contact_email+. Subclasse may override this method.
  def notification_emails
    [contact_email]
  end

  # gets recent documents in this profile, ordered from the most recent to the
  # oldest.
  #
  # +limit+ is the maximum number of documents to be returned. It defaults to
  # 10.
  def recent_documents(limit = 10, options = {}, pagination = true)
    self.articles.recent(limit, options, pagination)
  end

  def last_articles(limit = 10, options = {})
    options = { :limit => limit,
                :conditions => ["advertise = ? AND published = ? AND
                                 ((articles.type != ? and articles.type != ? and articles.type != ?) OR
                                 articles.type is NULL)",
                                 true, true, 'UploadedFile', 'RssFeed', 'Blog'],
                :order => 'articles.published_at desc, articles.id desc' }.merge(options)
    self.articles.find(:all, options)
  end

  class << self

    # finds a profile by its identifier. This method is a shortcut to
    # +find_by_identifier+.
    #
    # Examples:
    #
    #  person = Profile['username']
    #  org = Profile.['orgname']
    def [](identifier)
      self.find_by_identifier(identifier)
    end

  end

  def superior_instance
    environment
  end

  # returns +false+
  def person?
    self.kind_of?(Person)
  end

  def enterprise?
    self.kind_of?(Enterprise)
  end

  def organization?
    self.kind_of?(Organization)
  end

  def community?
    self.kind_of?(Community)
  end

  # returns false.
  def is_validation_entity?
    false
  end

  def url
    @url ||= generate_url(:controller => 'content_viewer', :action => 'view_page', :page => [])
  end

  def admin_url
    { :profile => identifier, :controller => 'profile_editor', :action => 'index' }
  end

  def tasks_url
    { :profile => identifier, :controller => 'tasks', :action => 'index', :host => default_hostname }
  end

  def leave_url(reload = false)
    { :profile => identifier, :controller => 'profile', :action => 'leave', :reload => reload }
  end

  def join_url
    { :profile => identifier, :controller => 'profile', :action => 'join' }
  end

  def join_not_logged_url
    { :profile => identifier, :controller => 'profile', :action => 'join_not_logged' }
  end

  def check_membership_url
    { :profile => identifier, :controller => 'profile', :action => 'check_membership' }
  end

  def add_url
    { :profile => identifier, :controller => 'profile', :action => 'add' }
  end

  def check_friendship_url
    { :profile => identifier, :controller => 'profile', :action => 'check_friendship' }
  end

  def public_profile_url
    generate_url(:profile => identifier, :controller => 'profile', :action => 'index')
  end

  def generate_url(options)
    url_options.merge(options)
  end

  def url_options
    options = { :host => default_hostname, :profile => (own_hostname ? nil : self.identifier) }
    options.merge(Noosfero.url_options)
  end

private :generate_url, :url_options

  def default_hostname
    @default_hostname ||= (hostname || environment.default_hostname)
  end

  def hostname
    if preferred_domain
      return preferred_domain.name
    else
      own_hostname
    end
  end

  def own_hostname
    domain = self.domains.first
    domain ? domain.name : nil
  end

  def possible_domains
    environment.domains + domains
  end

  def article_tags
    articles.tag_counts.inject({}) do |memo,tag|
      memo[tag.name] = tag.count
      memo
    end
  end

  def tagged_with(tag)
    self.articles.tagged_with(tag)
  end

  # Tells whether a specified profile has members or nor.
  #
  # On this class, returns <tt>false</tt> by default.
  def has_members?
    false
  end

  after_create :insert_default_article_set
  def insert_default_article_set
    if template
      copy_articles_from template
    else
      default_set_of_articles.each do |article|
        article.profile = self
        article.advertise = false
        article.save!
      end
    end
    self.save!
  end

  # Override this method in subclasses of Profile to create a default article
  # set upon creation. Note that this method will be called *only* if there is
  # no template for the type of profile (i.e. if the template was removed or in
  # the creation of the template itself).
  #
  # This method must return an array of pre-populated articles, which will be
  # associated to the profile before being saved. Example:
  #
  #   def default_set_of_articles
  #     [Blog.new(:name => 'Blog'), Gallery.new(:name => 'Gallery')]
  #   end
  #
  # By default, this method returns an empty array.
  def default_set_of_articles
    []
  end

  def copy_articles_from other
    other.top_level_articles.each do |a|
      copy_article_tree a
    end
    self.articles.reload
  end

  def copy_article_tree(article, parent=nil)
    return if article.is_a?(RssFeed)
    original_article = self.articles.find_by_name(article.name)
    if original_article
      num = 2
      new_name = original_article.name + ' ' + num.to_s
      while self.articles.find_by_name(new_name)
        num = num + 1
        new_name = original_article.name + ' ' + num.to_s
      end
      original_article.update_attributes!(:name => new_name)
    end
    article_copy = article.copy(:profile => self, :parent => parent, :advertise => false)
    if article.profile.home_page == article
      self.home_page = article_copy
    end
    article.children.each do |a|
      copy_article_tree a, article_copy
    end
  end

  # Adds a person as member of this Profile.
  def add_member(person)
    if self.has_members?
      if self.closed? && members.count > 0
        AddMember.create!(:person => person, :organization => self) unless self.already_request_membership?(person)
      else
        self.affiliate(person, Profile::Roles.admin(environment.id)) if members.count == 0
        self.affiliate(person, Profile::Roles.member(environment.id))
      end
    else
      raise _("%s can't have members") % self.class.name
    end
  end

  def remove_member(person)
    self.disaffiliate(person, Profile::Roles.all_roles(environment.id))
  end

  # adds a person as administrator os this profile
  def add_admin(person)
    self.affiliate(person, Profile::Roles.admin(environment.id))
  end

  def remove_admin(person)
    self.disaffiliate(person, Profile::Roles.admin(environment.id))
  end

  def add_moderator(person)
    if self.has_members?
      self.affiliate(person, Profile::Roles.moderator(environment.id))
    else
      raise _("%s can't has moderators") % self.class.name
    end
  end

  def self.recent(limit = nil)
    self.find(:all, :order => 'id desc', :limit => limit)
  end

  # returns +true+ if the given +user+ can see profile information about this
  # +profile+, and +false+ otherwise.
  def display_info_to?(user)
    if self.public?
      true
    else
      display_private_info_to?(user)
    end
  end

  after_save :update_category_from_region
  def update_category_from_region
    ProfileCategorization.remove_region(self)
    if region
      self.add_category(region)
    end
  end

  def accept_category?(cat)
    forbidden = [ ProductCategory, Region ]
    !forbidden.include?(cat.class)
  end

  include ActionView::Helpers::TextHelper
  def short_name(chars = 40)
    if self[:nickname].blank?
      truncate self.name, :length => chars, :omission => '...'
    else
      self[:nickname]
    end
  end

  def custom_header
    self[:custom_header] || environment && environment.custom_header
  end

  def custom_header_expanded
    header = custom_header
    if header
      %w[name short_name].each do |att|
        if self.respond_to?(att) && header.include?("{#{att}}")
          header.gsub!("{#{att}}", self.send(att))
        end
      end
      header
    end
  end

  def custom_footer
    self[:custom_footer] || environment && environment.custom_footer
  end

  def custom_footer_expanded
    footer = custom_footer
    if footer
      %w[contact_person contact_email contact_phone location address district address_reference economic_activity city state country zip_code].each do |att|
        if self.respond_to?(att) && footer.match(/\{[^{]*#{att}\}/)
          if !self.send(att).nil? && !self.send(att).blank?
            footer = footer.gsub(/\{([^{]*)#{att}\}/, '\1' + self.send(att))
          else
            footer = footer.gsub(/\{[^}]*#{att}\}/, '')
          end
        end
      end
      footer
    end
  end

  def public?
    visible && public_profile
  end

  def privacy_setting
    self.public? ? _('Public profile') : _('Private profile')
  end

  def themes
    Theme.find_by_owner(self)
  end

  def find_theme(the_id)
    themes.find { |item| item.id == the_id }
  end

  settings_items :layout_template, :type => String, :default => 'default'

  has_many :blogs, :source => 'articles', :class_name => 'Blog'

  def blog
    self.has_blog? ? self.blogs.first(:order => 'id') : nil
  end

  def has_blog?
    self.blogs.count.nonzero?
  end

  has_many :forums, :source => 'articles', :class_name => 'Forum'

  def forum
    self.has_forum? ? self.forums.first(:order => 'id') : nil
  end

  def has_forum?
    self.forums.count.nonzero?
  end

  def admins
    self.members_by_role(Profile::Roles.admin(environment.id))
  end

  def enable_contact?
    !environment.enabled?('disable_contact_' + self.class.name.downcase)
  end

  include Noosfero::Plugin::HotSpot
  
  def folder_types
    types = Article.folder_types
    plugins.dispatch(:content_types).each {|type|
      if type < Folder
        types << type.name
      end
    }
    types
  end

  def folders
    articles.folders(self)
  end

  def image_galleries
    articles.galleries
  end

  def blocks_to_expire_cache
    []
  end

  def cache_keys(params = {})
    []
  end

  validate :image_valid

  def image_valid
    unless self.image.nil?
      self.image.valid?
      self.image.errors.delete(:empty) # dont validate here if exists uploaded data
      self.image.errors.each do |attr,msg|
        self.errors.add(attr, msg)
      end
    end
  end

  # FIXME: horrible workaround to circular dependancy in environment.rb
  after_update do |profile|
    ProfileSweeper.new().after_update(profile)
  end

  # FIXME: horrible workaround to circular dependancy in environment.rb
  after_create do |profile|
    ProfileSweeper.new().after_create(profile)
  end

  def update_header_and_footer(header, footer)
    self.custom_header = header
    self.custom_footer = footer
    self.save(:validate => false)
  end

  def update_theme(theme)
    self.update_attribute(:theme, theme)
  end

  def update_layout_template(template)
    self.update_attribute(:layout_template, template)
  end

  def members_cache_key(params = {})
    page = params[:npage] || '1'
    cache_key + '-members-page-' + page
  end

  def more_recent_label
    _("Since: ")
  end

  def recent_actions
    tracked_actions.recent
  end

  def recent_notifications
    tracked_notifications.recent
  end

  def more_active_label
    amount = recent_actions.count
    amount += recent_notifications.count if organization?
    {
      0 => _('no activity'),
      1 => _('one activity')
    }[amount] || _("%s activities") % amount
  end

  def more_popular_label
    amount = self.members_count
    {
      0 => _('no members'),
      1 => _('one member')
    }[amount] || _("%s members") % amount
  end

  include Noosfero::Gravatar

  def profile_custom_icon(gravatar_default=nil)
    image.public_filename(:icon) if image.present?
  end

  def jid(options = {})
    domain = options[:domain] || environment.default_hostname
    "#{identifier}@#{domain}"
  end
  def full_jid(options = {})
    "#{jid(options)}/#{short_name}"
  end

  def is_on_homepage?(url, page=nil)
    if page
      page == self.home_page
    else
      url == '/' + self.identifier
    end
  end

  def opened_abuse_complaint
    abuse_complaints.opened.first
  end

  def disable
  end

  def control_panel_settings_button
    {:title => _('Edit Profile'), :icon => 'edit-profile'}
  end

  def self.identification
    name
  end

  # Override in your subclasses
  def activities
    []
  end

  def may_display_field_to? field, user = nil
    if not self.active_fields.include? field.to_s
      self.send "may_display_#{field}_to?", user rescue true
    else
      not (!self.public_fields.include? field.to_s and (!user or (user != self and !user.is_a_friend?(self))))
    end
  end

  def may_display_location_to? user = nil
    LOCATION_FIELDS.each do |field|
      return false if !self.may_display_field_to? field, user
    end
    return true
  end

  # field => privacy (e.g.: "address" => "public")
  def fields_privacy
    self.data[:fields_privacy]
  end

  def public_fields
    self.active_fields
  end

  def control_panel_settings_button
    {:title => _('Profile Info and settings'), :icon => 'edit-profile'}
  end

  def followed_by?(person)
    person.is_member_of?(self)
  end

  def display_private_info_to?(user)
    if user.nil?
      false
    else
      (user == self) || (user.is_admin?(self.environment)) || user.is_admin?(self) || user.memberships.include?(self)
    end
  end

  validates_inclusion_of :redirection_after_login, :in => Environment.login_redirection_options.keys, :allow_nil => true
  def preferred_login_redirection
    redirection_after_login.blank? ? environment.redirection_after_login : redirection_after_login
  end
end
