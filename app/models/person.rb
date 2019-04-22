# A person is the profile of an user holding all relationships with the rest of the system
class Person < Profile

  attr_accessible :organization, :contact_information, :sex, :birth_date, :cell_phone,
                  :comercial_phone, :jabber_id, :personal_website, :nationality, :schooling,
                  :schooling_status, :formation, :custom_formation, :area_of_study,
                  :custom_area_of_study, :professional_activity, :organization_website,
                  :following_articles, :editor

  SEARCH_FILTERS = {
    :order => %w[more_recent more_popular more_active],
    :display => %w[compact]
  }

  def self.type_name
    _('Person')
  end

  N_('person')

  def self.human_attribute_name_with_customization(attrib, options={})
    case attrib.to_sym
    when :lat
      _('Latitude')
    when :lng
      _('Longitude')
    when :full_address
      _('Full address')
    else
      _(self.human_attribute_name_without_customization(attrib))
    end
  end
  class << self
    alias_method_chain :human_attribute_name, :customization
  end

  acts_as_trackable :after_add => Proc.new {|p,t| notify_activity(t)}
  acts_as_accessor

  scope :members_of, lambda { |resources, field = ''|
    resources = Array(resources)
    joins = [:role_assignments]
    joins << :user if User.attribute_names.include? field

    conditions = resources.map {|resource| "role_assignments.resource_type = '#{resource.class.base_class.name}' AND role_assignments.resource_id = #{resource.id || -1}"}.join(' OR ')
    distinct.select('profiles.*').joins(joins).where([conditions])
  }

  scope :not_members_of, -> resources {
    resources = Array(resources)
    conditions = resources.map {|resource| "role_assignments.resource_type = '#{resource.class.base_class.name}' AND role_assignments.resource_id = #{resource.id || -1}"}.join(' OR ')
    distinct.select('profiles.*').where('"profiles"."id" NOT IN (SELECT DISTINCT profiles.id FROM "profiles" INNER JOIN "role_assignments" ON "role_assignments"."accessor_id" = "profiles"."id" AND "role_assignments"."accessor_type" = (\'Profile\') WHERE "profiles"."type" IN (\'Person\') AND (%s))' % conditions)
  }

  scope :by_role, -> roles {
    roles = Array(roles)
    distinct.select('profiles.*').joins(:role_assignments).where('role_assignments.role_id IN (?)', roles)
  }

  scope :not_friends_of, -> resources {
    resources = Array(resources)
    distinct.select('profiles.*').where('"profiles"."id" NOT IN (SELECT DISTINCT profiles.id FROM "profiles" INNER JOIN "friendships" ON "friendships"."person_id" = "profiles"."id" WHERE "friendships"."friend_id" IN (%s))' % resources.map(&:id))
  }

  def has_permission_with_admin?(permission, resource)
    return true if resource.blank? || resource.admins.include?(self)
    return true if resource.kind_of?(Profile) && resource.environment.admins.include?(self)
    has_permission_without_admin?(permission, resource)
  end
  alias_method_chain :has_permission?, :admin

  def has_permission_with_plugins?(permission, resource)
    permissions = [has_permission_without_plugins?(permission, resource)]
    permissions += plugins.map do |plugin|
      plugin.has_permission?(self, permission, resource)
    end
    permissions.include?(true)
  end
  alias_method_chain :has_permission?, :plugins

  # for eager loading
  has_many :memberships, through: :role_assignments, source: :resource, source_type: 'Profile'

  def memberships
    scopes = []
    plugins_scopes = plugins.dispatch_scopes(:person_memberships, self)
    scopes = plugins_scopes
    scopes << Profile.memberships_of(self)
    return scopes.first if scopes.size == 1
    ScopeTool.union *scopes
  end

  def memberships_by_role(role)
    memberships.where('role_assignments.role_id = ?', role.id)
  end

  has_many :comments, :foreign_key => :author_id
  has_many :article_followers, :dependent => :destroy
  has_many :following_articles, :class_name => 'Article', :through => :article_followers, :source => :article
  has_many :friendships, :dependent => :destroy
  has_many :friends, :class_name => 'Person', :through => :friendships
  has_many :circles
  has_many :push_subscriptions, as: :owner
  has_many :event_invitation

  scope :online, -> {
    joins(:user).where("users.chat_status != '' AND users.chat_status_at >= ?", DateTime.now - User.expires_chat_status_every.minutes)
  }

  has_many :requested_tasks, :class_name => 'Task', :foreign_key => :requestor_id, :dependent => :destroy

  has_many :abuse_reports, :foreign_key => 'reporter_id', :dependent => :destroy

  has_many :mailings

  has_many :scraps_sent, :class_name => 'Scrap', :foreign_key => :sender_id, :dependent => :destroy

  has_many :favorite_enterprise_people
  has_many :favorite_enterprises, source: :enterprise, through: :favorite_enterprise_people

  has_and_belongs_to_many :acepted_forums, :class_name => 'Forum', :join_table => 'terms_forum_people'
  has_and_belongs_to_many :articles_with_access, :class_name => 'Article', :join_table => 'article_privacy_exceptions'

  has_many :suggested_profiles, -> { order 'score DESC' },
    class_name: 'ProfileSuggestion', foreign_key: :person_id, dependent: :destroy
  has_many :suggested_people, -> {
    where 'profile_suggestions.suggestion_type = ? AND profile_suggestions.enabled = ?', 'Person', true
  }, through: :suggested_profiles, source: :suggestion
  has_many :suggested_communities, -> {
    where 'profile_suggestions.suggestion_type = ? AND profile_suggestions.enabled = ?', 'Community', true
  }, through: :suggested_profiles, source: :suggestion

  has_and_belongs_to_many :marked_scraps, :join_table => :private_scraps, :class_name => 'Scrap'

  scope :more_popular, -> { order 'profiles.friends_count DESC' }

  scope :abusers, -> {
    joins(:abuse_complaints).where('tasks.status = 3').distinct.select('profiles.*')
  }
  scope :non_abusers, -> {
    distinct.select("profiles.*").
    joins("LEFT JOIN tasks ON profiles.id = tasks.requestor_id AND tasks.type='AbuseComplaint'").
    where("tasks.status != 3 OR tasks.id is NULL")
  }

  scope :admins, -> { joins(:role_assignments => :role).where('roles.key = ?', 'environment_administrator') }
  scope :activated, -> { joins(:user).where('users.activation_code IS NULL AND users.activated_at IS NOT NULL') }
  scope :deactivated, -> { joins(:user).where('NOT (users.activation_code IS NULL AND users.activated_at IS NOT NULL)') }
  scope :recent, -> { joins(:user)}

  scope :with_role, -> role_id {
    distinct.joins(:role_assignments).
    where("role_assignments.role_id = #{role_id}")
  }

  after_destroy do |person|
    Friendship.where(friend_id: person.id).each{ |friendship| friendship.destroy }
  end

  belongs_to :user, :dependent => :delete

  acts_as_voter

  def can_change_homepage?
    !environment.enabled?('cant_change_homepage') || is_admin?
  end

  def can_control_scrap?(scrap)
    begin
      !self.scraps(scrap).nil?
    rescue
      false
    end
  end

  def receives_scrap_notification?
    true
  end

  def can_control_activity?(activity)
    self.tracked_notifications.exists?(activity)
  end

  def can_post_content?(profile, parent=nil)
    (!parent.nil? && (parent.allow_create?(self))) ||
      self.has_permission?('post_content', profile)
  end

  # Sets the identifier for this person. Raises an exception when called on a
  # existing person and the environment don't allow identifier changes
  def identifier=(value)
    unless self.new_record? || environment.enabled?(:enable_profile_url_change)
      raise ArgumentError.new(_('An existing person cannot be renamed.'))
    end
    self[:identifier] = value
  end

  def suggested_friend_groups
    (friend_groups.compact + [ _('friends'), _('work'), _('school'), _('family') ]).map {|i| i if !i.empty?}.compact.uniq
  end

  def friend_groups
    friendships.map { |item| item.group }.uniq
  end

  def add_friend(friend, group = nil)
    unless self.is_a_friend?(friend)
      friendship = self.friendships.build
      friendship.friend = friend
      friendship.group = group
      friendship.save
    end
  end

  def follow(profile, circles)
    circles = [circles] unless circles.is_a?(Array)
    circles.each do |new_circle|
      ProfileFollower.create(profile: profile, circle: new_circle)
    end
  end

  def update_profile_circles(profile, new_circles)
    profile_circles = ProfileFollower.with_profile(profile).with_follower(self).map(&:circle)
    circles_to_add = new_circles - profile_circles
    circles_to_remove = profile_circles - new_circles
    circles_to_add.each do |new_circle|
      ProfileFollower.create(profile: profile, circle: new_circle)
    end

    ProfileFollower.where('circle_id IN (?) AND profile_id = ?',
                          circles_to_remove.map(&:id), profile.id).destroy_all
  end

  def unfollow(profile)
    return if profile.in_social_circle?(self)
    ProfileFollower.with_follower(self).with_profile(profile).destroy_all
  end

  def remove_profile_from_circle(profile, circle)
    ProfileFollower.with_profile(profile).with_circle(circle).destroy_all
  end

  def already_request_friendship?(person)
    person.tasks.where(requestor_id: self.id, type: 'AddFriend', status: Task::Status::ACTIVE).first
  end

  def remove_friend(friend)
    Friendship.where(friend_id: friend, person_id: id).first.destroy
  end

  FIELDS = %w[
    description
    preferred_domain
    nickname
    sex
    birth_date
    nationality
    cell_phone
    comercial_phone
    personal_website
    jabber_id
    schooling
    formation
    custom_formation
    area_of_study
    custom_area_of_study
    professional_activity
    organization
    organization_website
    contact_phone
    contact_information
    location
  ] + LOCATION_FIELDS

  validates_multiparameter_assignments

  validate :presence_of_required_fields, :unless => :is_template
  validate :phone_format_is_valid, unless: :is_template

  def self.fields
    FIELDS
  end

  before_save do |person|
    person.custom_formation = nil if (! person.formation.nil? && person.formation != 'Others')
    person.custom_area_of_study = nil if (! person.area_of_study.nil? && person.area_of_study != 'Others')
    person.organization_website = person.maybe_add_http(person.organization_website)
  end
  include MaybeAddHttp

  def active_fields
    fields = environment ? environment.active_person_fields : []
    fields << 'email'
  end

  def required_fields
    environment ? environment.required_person_fields : []
  end

  def signup_fields
    environment ? environment.signup_person_fields : []
  end

  N_('Cell phone'); N_('Comercial phone'); N_('Nationality'); N_('Schooling'); N_('Area of study'); N_('Professional activity'); N_('Organization'); N_('Organization website');
  settings_items :cell_phone, :comercial_phone, :nationality, :schooling, :area_of_study, :professional_activity, :organization, :organization_website

  N_('Schooling status')
  settings_items :schooling_status

  N_('Education'); N_('Custom education'); N_('Custom area of study');
  settings_items :formation, :custom_formation, :custom_area_of_study

  N_('Contact information'); N_('City'); N_('State'); N_('Country'); N_('Sex'); N_('Zip code'); N_('District'); N_('Address reference')
  settings_items :photo, :contact_information, :sex

  extend SetProfileRegionFromCityState::ClassMethods
  set_profile_region_from_city_state

  def self.conditions_for_profiles(conditions, person)
    new_conditions = sanitize_sql(['role_assignments.accessor_id = ?', person])
    new_conditions << ' AND ' +  sanitize_sql(conditions) unless conditions.blank?
    new_conditions
  end

  def enterprises
    memberships.enterprises
  end

  def communities
    memberships.communities
  end

  def enterprises_with_post_permisson
    enterprises.select do |enterprise|
        has_permission?('publish_content', enterprise)
    end
  end

  def communities_with_post_permisson
    communities.select do |community|
        has_permission?('publish_content', community)
    end
  end

  validates_presence_of :user_id
  validates_uniqueness_of :user_id

  validates_associated :user

  validates :editor, inclusion: { in: lambda { |p| p.available_editors } }

  def email
    self.user.nil? ? nil : self.user.email
  end

  validates_each :email, :on => :update do |record,attr,value|
    if User.where('email = ? and id != ? and environment_id = ?', value, record.user.id, record.environment.id).first
      record.errors.add(attr, _('{fn} is already used by other user').fix_i18n)
    end
  end

  # Returns the user e-mail.
  def contact_email
    email
  end

  def email= (email)
    self.user.email = email if ! self.user.nil?
  end

  after_update do |person|
    person.user.save! unless person.user.changes.blank?
  end

  def is_admin?(environment = nil)
    environment ||= self.environment
    role_assignments.includes([:role, :resource]).select { |ra| ra.resource == environment }.map{|ra|ra.role.permissions}.any? do |ps|
      ps.any? do |p|
        ApplicationRecord::PERMISSIONS['Environment'].keys.include?(p)
      end
    end
  end

  def default_set_of_blocks
    return angular_theme_default_set_of_blocks if Theme.angular_theme?(environment.theme)
    links = [
      { name: _('Image gallery'), address: '/{profile}/gallery',        icon: 'photos'      },
      { name: _('Agenda'),        address: '/profile/{profile}/events', icon: 'event'       },
      { name: _('Blog'),          address: '/{profile}/blog',           icon: 'blog'        }
    ]
    [
      [MainBlock.new],
      [ProfileImageBlock.new(show_name: true), LinkListBlock.new(links: links), RecentDocumentsBlock.new],
      [CommunitiesBlock.new]
    ]
  end

  def angular_theme_default_set_of_blocks
    @boxes_limit = 2
    self.layout_template = 'rightbar'
    [
      [MenuBlock.new, MainBlock.new],
      [FriendsBlock.new, CommunitiesBlock.new, TagsCloudBlock.new]
    ]
  end

  def default_set_of_articles
    [
      Blog.new(:name => _('Blog')),
      Gallery.new(:name => _('Gallery')),
    ]
  end

  def email_domain
    user && user.email_domain || environment.default_hostname(true)
  end

  def email_addresses
    # TODO for now, only one e-mail address
    ['%s@%s' % [self.identifier, self.email_domain] ]
  end

  def default_template
    environment.person_default_template
  end

  def apply_type_specific_template(template)
    copy_communities_from(template)
  end

  def copy_communities_from(template)
    template.communities.each {|community| community.add_member(self)}
  end


  def self.with_pending_tasks
    Person.all.select{ |person| !person.tasks.pending.empty? or person.has_organization_pending_tasks? }
  end

  def has_organization_pending_tasks?
    self.memberships.any?{ |group| group.tasks.pending.any?{ |task| self.has_permission?(task.permission, group) } }
  end

  def organizations_with_pending_tasks
    self.memberships.select do |organization|
      organization.tasks.pending.any?{|task| self.has_permission?(task.permission, organization)}
    end
  end

  def pending_tasks_for_organization(organization)
    organization.tasks.pending.select{|task| self.has_permission?(task.permission, organization)}
  end

  def build_contact(profile, params = {})
    Contact.new(params.merge(:name => name, :email => email, :sender => self, :dest => profile))
  end

  def is_a_friend?(person)
    self.friends.include?(person)
  end

  has_and_belongs_to_many :refused_communities, :class_name => 'Community', :join_table => 'refused_join_community'

  def ask_to_join?(community)
    return false if !community.visible?
    return false if memberships.include?(community)
    return false if AddMember.where(requestor_id: self.id, target_id: community.id).first
    !refused_communities.include?(community)
  end

  def refuse_join(community)
    refused_communities << community
  end

  def blocks_to_expire_cache
    [CommunitiesBlock]
  end

  def cache_keys(params = {})
    result = []
    if params[:per_page]
      pages = (self.communities.count.to_f / params[:per_page].to_f).ceil
      (1..pages).each do |i|
        result << self.communities_cache_key(:npage => i.to_s)
      end
    end
    result
  end

  def communities_cache_key(params = {})
    page = params[:npage] || '1'
    cache_key + '-communities-page-' + page
  end

  def friends_cache_key(params = {})
    page = params[:npage] || '1'
    cache_key + '-friends-page-' + page
  end

  def manage_friends_cache_key(params = {})
    page = params[:npage] || '1'
    cache_key + '-manage-friends-page-' + page
  end

  def relationships_cache_key
    cache_key + '-profile-relationships'
  end

  def more_popular_label
    amount = self.friends.count
    {
      0 => _('none'),
      1 => _('one friend')
    }[amount] || _("%s friends") % amount
  end

  def self.notify_activity(tracked_action)
    Delayed::Job.enqueue NotifyActivityToProfilesJob.new(tracked_action.id)
  end

  def is_member_of?(profile)
    profile.try(:members).try(:include?, self)
  end

  def follows?(profile)
    return false if profile.nil?
    profile.followed_by?(self)
  end

  def each_friend(offset=0)
    while friend = self.friends.order(:id).offset(offset).first
      yield friend
      offset = offset + 1
    end
  end

  def wall_url
    generate_url(:profile => identifier, :controller => 'profile', :action => 'index', :anchor => 'profile-wall')
  end

  def is_last_admin?(organization)
    organization.admins == [self]
  end

  def is_last_admin_leaving?(organization, roles)
    is_last_admin?(organization) && roles.select {|role| role.key == "profile_admin"}.blank?
  end

  def leave(profile, reload = false)
    leave_hash = {:message => _('You just left %s.') % profile.name}
    if reload
      leave_hash.merge!({:reload => true})
    end
    profile.remove_member(self)
    leave_hash.to_json
  end

  def already_reported?(profile)
    abuse_reports.any? { |report| report.abuse_complaint.reported == profile && report.abuse_complaint.opened? }
  end

  def register_report(abuse_report, profile)
    AbuseComplaint.create!(:reported => profile, :target => profile.environment) if !profile.opened_abuse_complaint
    abuse_report.abuse_complaint = profile.opened_abuse_complaint
    abuse_report.reporter = self
    abuse_report.save!
  end

  def abuser?
    AbuseComplaint.finished.where(:requestor_id => self).count > 0
  end

  def disable
    self.visible = false
    user.password = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{identifier}--")
    user.password_confirmation = user.password
    save!
    user.save!
  end

  def exclude_verbs_on_activities
    %w[leave_scrap_to_self add_member_in_community reply_scrap_on_self]
  end

  # by default, all fields are private
  def public_fields
    self.fields_privacy.nil? ? [] : self.fields_privacy.reject{ |k, v| v != 'public' }.keys.map(&:to_s)
  end

  include Noosfero::Gravatar

  def profile_custom_icon(gravatar_default=nil)
    (self.image.present? && self.image.public_filename(:icon)) ||
    gravatar_profile_image_url(self.email, :size=>20, :d => gravatar_default)
  end

  settings_items :last_notification, :type => DateTime
  settings_items :notification_time, :type => :integer, :default => 0

  def notifier
    @notifier ||= PersonNotifier.new(self)
  end

  after_update do |person|
    person.notifier.reschedule_next_notification_mail
  end

  def remove_suggestion(profile)
    suggestion = suggested_profiles.find_by suggestion_id: profile.id
    suggestion.disable if suggestion
  end

  def allow_invitation_from?(person)
    person.has_permission?(:manage_friends, self)
  end

  def followed_profiles
    Profile.followed_by self
  end

  def editor?(editor)
    self.editor == editor
  end

  def in_social_circle?(person)
    self.is_a_friend?(person) || super
  end

  def available_editors
    available_editors = {
      Article::Editor::TINY_MCE => _('TinyMCE'),
      Article::Editor::TEXTILE => _('Textile')
    }
    available_editors.merge!({Article::Editor::RAW_HTML => _('Raw HTML')}) if self.is_admin?
    available_editors
  end

  def available_blocks(person)
    super(person) + [FavoriteEnterprisesBlock, CommunitiesBlock, EnterprisesBlock]
  end

  def pending_tasks
    Task.to(self).pending
  end

  def display_private_info_to?(person)
    super || (is_a_friend?(person) && display_to?(person))
  end

  def self.get_field_origin field
    if Person.column_names.include? field
      'self'
    elsif User.column_names.include? field
      'user'
    else
      'data'
    end
  end

  private

  # Special cases for presence_of_required_fields. You can set:
  # - cond: to be executed rather than checking if the field is blank
  # - unless: an exception for when the field is not present
  # - to_fields: map the errors to these fields rather than `field`
  REQUIRED_FIELDS_EXCEPTIONS = {
    custom_area_of_study: { unless: Proc.new{|p| p.area_of_study != 'Others' } },
    custom_formation: { unless: Proc.new{|p| p.formation != 'Others' } },
    location: { cond: Proc.new{|p| p.lat.nil? || p.lng.nil? }, to_fields: [:lat, :lng] }
  }

  def presence_of_required_fields
    self.required_fields.each do |field|
      opts = REQUIRED_FIELDS_EXCEPTIONS[field.to_sym] || {}
      if (opts[:cond] ? opts[:cond].call(self) : self.send(field).blank?)
        unless opts[:unless].try(:call, self)
          fields = opts[:to_fields] || field
          fields = fields.kind_of?(Array) ? fields : [fields]
          fields.each do |to_field|
            self.errors.add_on_blank(to_field)
          end
        end
      end
    end
  end

  PHONE_FIELDS = %i(cell_phone comercial_phone contact_phone)
  PHONE_FORMAT = /^\d{5,15}$/

  def phone_format_is_valid
    PHONE_FIELDS.each do |field|
      if self.send(field).present? && self.send(field) !~ PHONE_FORMAT
        self.errors.add(field, _('is not valid. Check the digits and '\
                                 'make sure to use only numbers.'))
      end
    end
  end
end
