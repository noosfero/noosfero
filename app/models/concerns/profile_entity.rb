module ProfileEntity
  extend ActiveSupport::Concern

  included do
    attr_accessible :name, :identifier, :environment

    validates_presence_of :identifier, :name

    belongs_to :environment
    has_many :search_terms, :as => :context
    has_many :abuse_complaints, :as => :reported, :foreign_key => 'requestor_id', :dependent => :destroy

    before_create :set_default_environment

    scope :recent, -> limit=nil { order('id DESC').limit(limit) }

  end

  def disable
    self.visible = false
    self.save
  end

  def enable
    self.visible = true
    self.save
  end

  def opened_abuse_complaint
    abuse_complaints.opened.first
  end

  def set_default_environment
    if self.environment.nil?
      self.environment = Environment.default
    end
    true
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

  include ActionView::Helpers::TextHelper
  def short_name(chars = 40)
    if self[:nickname].blank?
      if chars
        truncate self.name, length: chars, omission: '...'
      else
        self.name
      end
    else
      self[:nickname]
    end
  end

  def to_liquid
    HashWithIndifferentAccess.new :name => name, :identifier => identifier
  end

  # Tells whether a specified profile has members or nor.
  #
  # On this class, returns <tt>false</tt> by default.
  def has_members?
    false
  end

  def apply_type_specific_template(template)
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

  def blocks_to_expire_cache
    []
  end

  def cache_keys(params = {})
    []
  end

  def members_cache_key(params = {})
    page = params[:npage] || '1'
    sort = (params[:sort] ==  'desc') ? params[:sort] : 'asc'
    cache_key + '-members-page-' + page + '-' + sort
  end

  def more_recent_label
    _("Since: ")
  end

  def control_panel_settings_button
    {:title => _('Edit Profile'), :icon => 'edit-profile'}
  end

  def control_panel_settings_button
    {:title => _('Profile Info and settings'), :icon => 'edit-profile'}
  end

  def exclude_verbs_on_activities
    %w[]
  end

  def allow_invitation_from(person)
    false
  end

  def allow_post_content?(person = nil)
    person.kind_of?(Profile) && person.has_permission?('post_content', self)
  end

  def allow_edit?(person = nil)
    person.kind_of?(Profile) && person.has_permission?('edit_profile', self)
  end

  def allow_destroy?(person = nil)
    person.kind_of?(Profile) && person.has_permission?('destroy_profile', self)
  end

  module ClassMethods

    def identification
      name
    end

  end

end
