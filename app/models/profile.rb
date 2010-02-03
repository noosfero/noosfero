# A Profile is the representation and web-presence of an individual or an
# organization. Every Profile is attached to its Environment of origin,
# which by default is the one returned by Environment:default.
class Profile < ActiveRecord::Base

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
      [admin(env_id), moderator(env_id), member(env_id)]
    end
    def self.all_roles(env_id)
      [admin(env_id), member(env_id), moderator(env_id), owner(env_id), editor(env_id)]
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
  }

  acts_as_accessible

  acts_as_having_boxes

  acts_as_searchable :additional_fields => [ :extra_data_for_index ]

  acts_as_taggable

  named_scope :visible, :conditions => { :visible => true }

  # FIXME ugly workaround
  def self.human_attribute_name(attrib)
      _(self.superclass.human_attribute_name(attrib))
  end

  class_inheritable_accessor :extra_index_methods
  self.extra_index_methods = []

  def extra_data_for_index
    self.class.extra_index_methods.map { |meth| meth.to_proc.call(self) }.flatten
  end

  def self.extra_data_for_index(sym = nil, &block)
    self.extra_index_methods.push(sym) if sym
    self.extra_index_methods.push(block) if block_given?
  end

  acts_as_having_settings :field => :data

  settings_items :public_content, :type => :boolean, :default => true
  settings_items :description

  validates_length_of :description, :maximum => 550, :allow_nil => true

  acts_as_mappable :default_units => :kms

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
  environment
  webmaster
  info
  root
  assets
  doc
  ]

  belongs_to :user

  has_many :domains, :as => :owner
  belongs_to :preferred_domain, :class_name => 'Domain', :foreign_key => 'preferred_domain_id'
  belongs_to :environment

  has_many :articles, :dependent => :destroy
  belongs_to :home_page, :class_name => Article.name, :foreign_key => 'home_page_id'

  acts_as_having_image

  has_many :consumptions
  has_many :consumed_product_categories, :through => :consumptions, :source => :product_category

  has_many :tasks, :dependent => :destroy, :as => 'target'

  has_many :events, :source => 'articles', :class_name => 'Event', :order => 'name'

  %w[ pending finished ].each do |status|
    class_eval <<-CODE
      def all_#{status}_tasks
        env_tasks = []
        if self.person?
          env_tasks = Environment.find(:all).select{ |env| self.is_admin?(env) }.map{ |env| env.tasks.#{status} }.flatten
        end
        tasks.#{status} + env_tasks
      end
    CODE
  end

  def find_in_all_tasks(task_id)
    if tasks.exists?(task_id)
      return tasks.find(task_id)
    else
      if self.person?
        environments_admin = Environment.find(:all).select{ |env| self.is_admin?(env) }
        task = environments_admin.select{ |env| env.tasks.exists?(task_id) }.map{ |i| i.tasks.find(task_id) }
        return task.first unless task.empty?
      end
    end
    return nil
  end

  has_many :profile_categorizations, :conditions => [ 'categories_profiles.virtual = ?', false ]
  has_many :categories, :through => :profile_categorizations

  def interests
    categories.select {|item| !item.is_a?(Region)}
  end

  belongs_to :region
  
  def location(separator = ' - ')
    myregion = self.region
    if myregion
      myregion.hierarchy.reverse.first(2).map(&:name).join(separator)
    else
      %w[address city state country_name zip_code ].map {|item| (self.respond_to?(item) && !self.send(item).blank?) ? self.send(item) : nil }.compact.join(separator)
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
    CountriesHelper.instance.lookup(country) if respond_to?(:country)
  end

  def pending_categorizations
    @pending_categorizations ||= []
  end

  def add_category(c)
    if self.id
      ProfileCategorization.add_category_to_profile(c, self)
    else
      pending_categorizations << c
    end
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
            self.boxes[i].blocks << block.new
          end
        end
      end
    end

    true
  end

  def copy_blocks_from(profile)
    self.boxes.destroy_all
    profile.boxes.each do |box|
      self.boxes << Box.new(:position => box.position)
      box.blocks.each do |block|
        self.boxes[-1].blocks << block.class.new(:title => block[:title], :settings => block.settings, :position => block.position)
      end
    end
  end

  # this method should be overwritten to provide the correct template
  def template
    nil
  end

  def apply_template(template, options = {:copy_articles => true})
    copy_blocks_from(template)
    copy_articles_from(template) if options[:copy_articles]

    # copy interesting attributes
    self.layout_template = template.layout_template
    self.theme = template.theme
    self.custom_footer = template[:custom_footer]
    self.custom_header = template[:custom_header]

    # flush
    self.save_without_validation!
  end

  xss_terminate :only => [ :name, :nickname, :address, :contact_phone, :description ]
  xss_terminate :only => [ :custom_footer, :custom_header ], :with => 'white_list'

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
  def recent_documents(limit = 10, options = {})
    self.articles.recent(limit, options)
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

  def leave_url
    { :profile => identifier, :controller => 'profile', :action => 'leave' }
  end

  def join_url
    { :profile => identifier, :controller => 'profile', :action => 'join' }
  end

  def public_profile_url
    generate_url(:profile => identifier, :controller => 'profile', :action => 'index')
  end

  def generate_url(options)
    url_options.merge(options)
  end

  def url_options
    options = { :host => default_hostname, :profile => (own_hostname ? nil : self.identifier) }
    Noosfero.url_options.merge(options)
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

  def find_tagged_with(tag)
    # FIXME: this can be SLOW
    articles.select {|item| item.tags.map(&:name).include?(tag) }
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
      # a default homepage
      hp = default_homepage(:name => _("My home page"), :body => _("<p>This is a default homepage created for me. It can be changed though the control panel.</p>"), :advertise => false)
      hp.profile = self
      hp.save!
      self.home_page = hp

      # a default rss feed
      feed = RssFeed.new(:name => 'feed')
      self.articles << feed

      # a default private folder if public
      if self.public?
       folder = Folder.new(:name => _("Intranet"), :public_article => false)
       self.articles << folder
      end
    end
    self.save!
  end

  def copy_articles_from other
    other.top_level_articles.each do |a|
      copy_article_tree a
    end
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
      if self.closed?
        AddMember.create!(:person => person, :organization => self) unless self.already_request_membership?(person)
      else
        self.affiliate(person, Profile::Roles.member(environment.id))
      end
    else
      raise _("%s can't has members") % self.class.name
    end
  end
  
  def remove_member(person)
    self.disaffiliate(person, Profile::Roles.all_roles(environment.id))
  end

  # adds a person as administrator os this profile
  def add_admin(person)
    self.affiliate(person, Profile::Roles.admin(environment.id))
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

  def default_homepage(attrs)
    TinyMceArticle.new(attrs)
  end

  include ActionView::Helpers::TextHelper
  def short_name
    if self[:nickname].blank?
      truncate self.name, 15, '...'
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
      %w[contact_person contact_email contact_phone location address economic_activity city state country zip_code].each do |att|
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

  def theme
    self[:theme] || environment && environment.theme || 'default'
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

  def boxes_limit
    LayoutTemplate.find(layout_template).number_of_boxes
  end

  has_many :blogs, :source => 'articles', :class_name => 'Blog'

  def blog
    self.has_blog? ? self.blogs.first(:order => 'id') : nil
  end

  def has_blog?
    self.blogs.count.nonzero?
  end

  def admins
    self.members_by_role(Profile::Roles.admin(environment.id))
  end

  def enable_contact?
    !environment.enabled?('disable_contact_' + self.class.name.downcase)
  end

  def folders
    articles.folders
  end

  def image_galleries
    folders.select { |folder| folder.display_as_gallery?}
  end

  def blocks_to_expire_cache
    []
  end

  def cache_keys(params = {})
    []
  end

  def validate
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
    self.save(false)
  end

  def update_theme(theme)
    self.update_attribute(:theme, theme)
  end

  def update_layout_template(template)
    self.update_attribute(:layout_template, template)
  end

  protected

    def display_private_info_to?(user)
      if user.nil?
        false
      else
        (user == self) || (user.is_admin?(self.environment)) || (user.memberships.include?(self))
      end
    end
end
