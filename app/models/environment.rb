# A Environment is like a website to be hosted in the platform. It may
# contain multiple Profile's and can be identified by several different
# domains.
class Environment < ActiveRecord::Base

  PERMISSIONS['Environment'] = {
    'view_environment_admin_panel' => N_('View environment admin panel'),
    'edit_environment_features' => N_('Edit environment features'),
    'edit_environment_design' => N_('Edit environment design'),
    'manage_environment_categories' => N_('Manage environment categories'),
    'manage_environment_roles' => N_('Manage environment roles'),
    'manage_environment_validators' => N_('Manage environment validators'),
  }

  module Roles
    def self.admin
      Role.find_by_key('environment_administrator')
    end
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

  # #################################################
  # Validations
  # #################################################

  # <tt>name</tt> is mandatory
  validates_presence_of :name

  # only one environment can be the default one
  validates_uniqueness_of :is_default, :if => (lambda do |environment| environment.is_default? end), :message => _('Only one Virtual Community can be the default one')

  validates_format_of :contact_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |record| ! record.contact_email.blank? })

  xss_terminate :only => [ :description, :message_for_disabled_enterprise ], :with => 'white_list'

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

  def default_hostname
    if self.domains(true).empty?
      'localhost'
    else
      self.domains.find(:first, :order => 'id').name
    end
  end

  def to_s
    self.name || '?'
  end

  has_many :articles, :through => :profiles
  def recent_documents(limit = 10)
    self.articles.recent(limit)
  end

  has_many :events, :through => :profiles, :source => :articles, :class_name => 'Event' 

end
