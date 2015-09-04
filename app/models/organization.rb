# Represents any organization of the system
class Organization < Profile

  attr_accessible :moderated_articles, :foundation_year, :contact_person, :acronym, :legal_form, :economic_activity, :management_information, :cnpj, :display_name, :enable_contact_us

  SEARCH_FILTERS = {
    :order => %w[more_recent more_popular more_active],
    :display => %w[compact]
  }

  # An Organization is considered visible to a given person if one of the
  # following conditions are met:
  #   1) The user is an environment administrator.
  #   2) The user is an administrator of the organization.
  #   3) The user is a member of the organization and the organization is
  #   visible.
  #   4) The user is not a member of the organization but the organization is
  #   visible, public and enabled.
  def self.visible_for_person(person)
    joins('LEFT JOIN "role_assignments" ON ("role_assignments"."resource_id" = "profiles"."id"
          AND "role_assignments"."resource_type" = \'Profile\') OR (
          "role_assignments"."resource_id" = "profiles"."environment_id" AND
          "role_assignments"."resource_type" = \'Environment\' )')
    .joins('LEFT JOIN "roles" ON "role_assignments"."role_id" = "roles"."id"')
    .where(
      ['( (roles.key = ? OR roles.key = ?) AND role_assignments.accessor_type = ? AND role_assignments.accessor_id = ? )
        OR
        ( ( ( role_assignments.accessor_type = ? AND role_assignments.accessor_id = ? ) OR
            ( profiles.public_profile = ? AND profiles.enabled = ? ) ) AND
          ( profiles.visible = ? ) )',
      'profile_admin', 'environment_administrator', Profile.name, person.id,
      Profile.name, person.id,  true, true, true]
    ).uniq
  end

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

  has_many :custom_roles, :class_name => 'Role', :foreign_key => :profile_id

  scope :more_popular, :order => 'members_count DESC'

  validate :presence_of_required_fieds, :unless => :is_template

  def self.notify_activity tracked_action
    Delayed::Job.enqueue NotifyActivityToProfilesJob.new(tracked_action.id)
  end

  def presence_of_required_fieds
    self.required_fields.each do |field|
      if self.send(field).blank?
        self.errors.add_on_blank(field)
      end
    end
  end

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
    template_id
    district
    address_reference
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

  N_('Display name'); N_('Description'); N_('Contact person'); N_('Contact email'); N_('Acronym'); N_('Foundation year'); N_('Legal form'); N_('Economic activity'); N_('Management information'); N_('Tag list'); N_('District'); N_('Address reference')
  settings_items :display_name, :description, :contact_person, :contact_email, :acronym, :foundation_year, :legal_form, :economic_activity, :management_information, :district, :address_reference

  settings_items :zip_code, :city, :state, :country

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
      [RecentDocumentsBlock.new]
    ]
  end

  def default_set_of_articles
    [
      Blog.new(:name => _('Blog')),
      Gallery.new(:name => _('Gallery')),
    ]
  end

  def short_name chars = 40
    s = self.display_name
    s = super(chars) if s.blank?
    s
  end

  def notification_emails
    emails = [contact_email].select(&:present?) + admins.map(&:email)
    if emails.empty?
      emails << environment.contact_email
    end
    emails
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

  def disable
    self.visible = false
    save!
  end

  def allow_invitation_from?(person)
    (followed_by?(person) && self.allow_members_to_invite) || person.has_permission?('invite-members', self)
  end

  def is_admin?(user)
    self.admins.where(:id => user.id).exists?
  end

end
