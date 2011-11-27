# Represents any organization of the system
class Organization < Profile

  settings_items :closed, :type => :boolean, :default => false
  def closed?
    closed
  end

  before_save do |organization|
    organization.closed = true if !organization.public_profile?
  end

  settings_items :moderated_articles, :type => :boolean, :default => false
  def moderated_articles?
    moderated_articles
  end

  has_one :validation_info

  has_many :validations, :class_name => 'CreateEnterprise', :foreign_key => :target_id

  has_many :mailings, :class_name => 'OrganizationMailing', :foreign_key => :source_id, :as => 'source'

  named_scope :more_popular,
    :select => "#{Profile.qualified_column_names}, count(resource_id) as total",
    :group => Profile.qualified_column_names,
    :joins => "LEFT OUTER JOIN role_assignments ON profiles.id = role_assignments.resource_id",
    :order => "total DESC"

  named_scope :more_active,
    :select => "#{Profile.qualified_column_names}, count(action_tracker.id) as total",
    :joins => "LEFT OUTER JOIN action_tracker ON profiles.id = action_tracker.target_id",
    :group => Profile.qualified_column_names,
    :order => 'total DESC',
    :conditions => ['action_tracker.created_at >= ? OR action_tracker.id IS NULL', ActionTracker::Record::RECENT_DELAY.days.ago]

  def validation_methodology
    self.validation_info ? self.validation_info.validation_methodology : nil
  end

  def validation_restrictions
    self.validation_info ? self.validation_info.restrictions : nil
  end

  def pending_validations
    validations.pending
  end

  def find_pending_validation(code)
    validations.pending.find(:first, :conditions => {:code => code})
  end

  def processed_validations
    validations.finished
  end

  def find_processed_validation(code)
    validations.finished.find(:first, :conditions => {:code => code})
  end

  def is_validation_entity?
    !self.validation_info.nil?
  end

  FIELDS = %w[
    display_name
    description
    contact_person
    contact_email
    contact_phone
    legal_form
    economic_activity
    management_information
    address
    zip_code
    city
    state
    country
    tag_list
  ]

  def self.fields
    FIELDS
  end

  def required_fields
    []
  end

  def active_fields
    []
  end

  def signup_fields
    []
  end

  N_('Display name'); N_('Description'); N_('Contact person'); N_('Contact email'); N_('Acronym'); N_('Foundation year'); N_('Legal form'); N_('Economic activity'); N_('Management information'); N_('Tag list')
  settings_items :display_name, :description, :contact_person, :contact_email, :acronym, :foundation_year, :legal_form, :economic_activity, :management_information

  validates_format_of :foundation_year, :with => Noosfero::Constants::INTEGER_FORMAT
  validates_format_of :contact_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |org| !org.contact_email.blank? })
  validates_as_cnpj :cnpj

  xss_terminate :only => [ :acronym, :contact_person, :contact_email, :legal_form, :economic_activity, :management_information ], :on => 'validation'

  # Yes, organizations have members.
  #
  # Returns <tt>true</tt>.
  def has_members?
    true
  end

  def default_set_of_blocks
    links = [
      {:name => _("Community's profile"), :address => '/profile/{profile}', :icon => 'ok'},
      {:name => _('Invite Friends'), :address => '/profile/{profile}/invite/friends', :icon => 'send'},
      {:name => _('Agenda'), :address => '/profile/{profile}/events', :icon => 'event'},
      {:name => _('Image gallery'), :address => '/{profile}/gallery', :icon => 'photos'},
      {:name => _('Blog'), :address => '/{profile}/blog', :icon => 'edit'},
    ]
    [
      [MainBlock.new],
      [ProfileImageBlock.new, LinkListBlock.new(:links => links)],
      [MembersBlock.new, RecentDocumentsBlock.new]
    ]
  end

  def default_set_of_articles
    [
      Blog.new(:name => _('Blog')),
      Gallery.new(:name => _('Gallery')),
    ]
  end

  def notification_emails
    [contact_email.blank? ? nil : contact_email].compact + admins.map(&:email)
  end

  def already_request_membership?(person)
    self.tasks.pending.find_by_requestor_id(person.id, :conditions => { :type => 'AddMember' })
  end

  def jid(options = {})
    super({:domain => "conference.#{environment.default_hostname}"}.merge(options))
  end

  def receives_scrap_notification?
    false
  end

  def members_to_json
    members.map { |member| {:id => member.id, :name => member.name} }.to_json
  end

  def members_by_role_to_json(role)
    members_by_role(role).map { |member| {:id => member.id, :name => member.name} }.to_json
  end

end
