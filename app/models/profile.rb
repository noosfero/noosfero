# A Profile is the representation and web-presence of an individual or an
# organization. Every Profile is attached to its Environment of origin,
# which by default is the one returned by Environment:default.
class Profile < ActiveRecord::Base

  module Roles
    def self.admin
      ::Role.find_by_key('profile_admin')
    end
    def self.member
      ::Role.find_by_key('profile_member')
    end
    def self.moderator
      ::Role.find_by_key('profile_moderator')
    end
    def self.owner
      ::Role.find_by_key('profile_owner')
    end
    def self.editor
      ::Role.find_by_key('profile_editor')
    end
    def self.all_roles
      [admin, member, moderator, owner, editor]
    end
  end

  PERMISSIONS['Profile'] = {
    'edit_profile'        => N_('Edit profile'),
    'destroy_profile'     => N_('Destroy profile'),
    'manage_memberships'  => N_('Manage memberships'),
    'post_content'        => N_('Post content'),
    'edit_profile_design' => N_('Edit profile design'),
    'manage_products'     => N_('Manage products'),
    'manage_friends'      => N_('Manage friends'),
    'validate_enterprise' => N_('Validate enterprise'),
    'perform_task'        => N_('Perform task'),
    'moderate_comments'   => N_('Moderate comments'),
    'edit_appearance'     => N_('Edit appearance'),
  }

  acts_as_accessible

  acts_as_having_boxes

  acts_as_searchable :additional_fields => [ :extra_data_for_index ]

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
  ]

  belongs_to :user

  has_many :domains, :as => :owner
  belongs_to :environment

  has_many :articles, :dependent => :destroy
  belongs_to :home_page, :class_name => Article.name, :foreign_key => 'home_page_id'

  acts_as_having_image

  has_many :consumptions
  has_many :consumed_product_categories, :through => :consumptions, :source => :product_category

  has_many :tasks, :foreign_key => :target_id

  has_many :profile_categorizations, :conditions => [ 'categories_profiles.virtual = ?', false ]
  has_many :categories, :through => :profile_categorizations

  belongs_to :region
  
  def location
    myregion = self.region
    if myregion
      myregion.name
    else
      ''
    end
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
      add_category(Category.find(item))
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
  
  # Sets the identifier for this profile. Raises an exception when called on a
  # existing profile (since profiles cannot be renamed)
  def identifier=(value)
    unless self.new_record?
      raise ArgumentError.new(_('An existing profile cannot be renamed.'))
    end
    self[:identifier] = value
  end

  validates_presence_of :identifier, :name
  validates_format_of :identifier, :with => IDENTIFIER_FORMAT
  validates_exclusion_of :identifier, :in => RESERVED_IDENTIFIERS
  validates_uniqueness_of :identifier

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
      copy_blocks_from template
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
        self.boxes[-1].blocks << block.class.new(:title => block.title, :settings => block.settings, :position => block.position)
      end
    end
  end

  # this method should be overwritten to provide the correct template
  def template
    nil
  end

  xss_terminate :only => [ :name, :nickname, :address, :contact_phone ]

  # returns the contact email for this profile. By default returns the the
  # e-mail of the owner user.
  #
  # Subclasses may -- and should -- override this method.
  def contact_email
    self.user ? self.user.email : nil
  end

  # gets recent documents in this profile, ordered from the most recent to the
  # oldest.
  #
  # +limit+ is the maximum number of documents to be returned. It defaults to
  # 10.
  def recent_documents(limit = 10)
    self.articles.recent(limit)
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
    if self.domains.empty?
      generate_url(:controller => 'content_viewer', :action => 'view_page', :page => [])
    else
      Noosfero.url_options.merge({ :host => self.domains.first.name, :controller => 'content_viewer', :action => 'view_page', :page => []})
    end
  end

  def admin_url
    generate_url(:controller => 'profile_editor', :action => 'index')
  end

  def public_profile_url
    generate_url(:controller => 'profile', :action => 'index')
  end

  def generate_url(options)
    url_options.merge(options)
  end

  def url_options
    Noosfero.url_options.merge({ :host => self.environment.default_hostname, :profile => self.identifier})
  end

  # FIXME this can be SLOW
  def tags
    totals = {}
    articles.each do |article|
      article.tags.each do |tag|
        if totals[tag.name]
          totals[tag.name] += 1
        else
          totals[tag.name] = 1
        end
      end
    end
    totals
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
        AddMember.create!(:person => person, :organization => self)
      else
        self.affiliate(person, Profile::Roles.member)
      end
    else
      raise _("%s can't has members") % self.class.name
    end
  end
  
  def remove_member(person)
    self.disaffiliate(person, Profile::Roles.all_roles)
  end

  # adds a person as administrator os this profile
  def add_admin(person)
    self.affiliate(person, Profile::Roles.admin)
  end

  def add_moderator(person)
    if self.has_members?
      self.affiliate(person, Profile::Roles.moderator)
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
    if self.public_profile
      true
    else
      if user.nil?
        false
      else
        # other possibilities would come here
        (user == self) || (user.memberships.include?(self))
      end
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
      truncate self.identifier, 15, '...'
    else
      self[:nickname]
    end
  end

  def custom_header
    self[:custom_header] || environment.custom_header
  end

  def custom_footer
    self[:custom_footer] || environment.custom_footer
  end

  def theme
    self[:theme] || environment.theme
  end

  def public?
    public_profile
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

end
