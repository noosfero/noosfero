# A person is the profile of an user holding all relationships with the rest of the system
class Person < Profile

  SEARCH_FILTERS += %w[
    more_popular
    more_active
  ]

  def self.type_name
    _('Person')
  end

  acts_as_trackable :after_add => Proc.new {|p,t| notify_activity(t)}
  acts_as_accessor

  @@human_names = {}

  def self.human_names
    @@human_names
  end

  # FIXME ugly workaround
  def self.human_attribute_name(attrib)
    human_names.each do |key, human_text|
      return human_text if attrib.to_sym == key.to_sym
    end
    super
  end

  named_scope :members_of, lambda { |resources|
    resources = [resources] if !resources.kind_of?(Array)
    conditions = resources.map {|resource| "role_assignments.resource_type = '#{resource.class.base_class.name}' AND role_assignments.resource_id = #{resource.id || -1}"}.join(' OR ')
    { :select => 'DISTINCT profiles.*', :joins => :role_assignments, :conditions => [conditions] }
  }

  def has_permission_with_plugins?(permission, profile)
    permissions = [has_permission_without_plugins?(permission, profile)]
    permissions += plugins.map do |plugin|
      plugin.has_permission?(self, permission, profile)
    end
    permissions.include?(true)
  end
  alias_method_chain :has_permission?, :plugins

  def memberships
    Profile.memberships_of(self)
  end

  has_many :friendships, :dependent => :destroy
  has_many :friends, :class_name => 'Person', :through => :friendships

  named_scope :online, lambda { { :include => :user, :conditions => ["users.chat_status != '' AND users.chat_status_at >= ?", DateTime.now - User.expires_chat_status_every.minutes] } }

  has_many :requested_tasks, :class_name => 'Task', :foreign_key => :requestor_id, :dependent => :destroy

  has_many :abuse_reports, :foreign_key => 'reporter_id', :dependent => :destroy

  has_many :mailings

  has_many :scraps_sent, :class_name => 'Scrap', :foreign_key => :sender_id, :dependent => :destroy

  named_scope :more_popular,
      :select => "#{Profile.qualified_column_names}, count(friend_id) as total",
      :group => Profile.qualified_column_names,
      :joins => "LEFT OUTER JOIN friendships on profiles.id = friendships.person_id",
      :order => "total DESC"

  named_scope :more_active,
    :select => "#{Profile.qualified_column_names}, count(action_tracker.id) as total",
    :joins => "LEFT OUTER JOIN action_tracker ON profiles.id = action_tracker.user_id",
    :group => Profile.qualified_column_names,
    :order => 'total DESC',
    :conditions => ['action_tracker.created_at >= ? OR action_tracker.id IS NULL', ActionTracker::Record::RECENT_DELAY.days.ago]

  named_scope :abusers, :joins => :abuse_complaints, :conditions => ['tasks.status = 3'], :select => 'DISTINCT profiles.*'
  named_scope :non_abusers, :joins => "LEFT JOIN tasks ON profiles.id = tasks.requestor_id AND tasks.type='AbuseComplaint'", :conditions => ["tasks.status != 3 OR tasks.id is NULL"], :select => "DISTINCT profiles.*"

  after_destroy do |person|
    Friendship.find(:all, :conditions => { :friend_id => person.id}).each { |friendship| friendship.destroy }
  end

  belongs_to :user, :dependent => :delete

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

  # Sets the identifier for this person. Raises an exception when called on a
  # existing person (since peoples' identifiers cannot be changed)
  def identifier=(value)
    unless self.new_record?
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
      self.friendships.build(:friend => friend, :group => group).save!
   end
  end

  def already_request_friendship?(person)
    person.tasks.find_by_requestor_id(self.id, :conditions => { :type => 'AddFriend' })
  end

  def remove_friend(friend)
    Friendship.find(:first, :conditions => {:friend_id => friend, :person_id => id}).destroy
  end

  FIELDS = %w[
  preferred_domain
  nickname
  sex
  address
  zip_code
  city
  state
  country
  nationality
  birth_date
  cell_phone
  comercial_phone
  schooling
  professional_activity
  organization
  organization_website
  area_of_study
  custom_area_of_study
  formation
  custom_formation
  contact_phone
  contact_information
  description
  image
  district
  address_reference
  ]

  validates_multiparameter_assignments

  validates_each :birth_date do |record,attr,value|
    if value && value.year == 1
      record.errors.add(attr)
    end
  end

  def self.fields
    FIELDS
  end

  def validate
    super
    self.required_fields.each do |field|
      if self.send(field).blank?
        unless (field == 'custom_area_of_study' && self.area_of_study != 'Others') || (field == 'custom_formation' && self.formation != 'Others')
          self.errors.add_on_blank(field)
        end
      end
    end
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
  settings_items :photo, :contact_information, :sex, :city, :state, :country, :zip_code, :district, :address_reference

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

  validates_presence_of :user_id
  validates_uniqueness_of :user_id

  validates_associated :user

  def email
    self.user.nil? ? nil : self.user.email
  end

  validates_each :email, :on => :update do |record,attr,value|
    if User.find(:first, :conditions => ['email = ? and id != ? and environment_id = ?', value, record.user.id, record.environment.id])
      record.errors.add(attr, _('%{fn} is already used by other user').fix_i18n)
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
    person.user.save!
  end

  def is_admin?(environment = nil)
    environment ||= self.environment
    role_assignments.includes([:role, :resource]).select { |ra| ra.resource == environment }.map{|ra|ra.role.permissions}.any? do |ps|
      ps.any? do |p|
        ActiveRecord::Base::PERMISSIONS['Environment'].keys.include?(p)
      end
    end
  end

  def default_set_of_blocks
    links = [
      {:name => _('Profile'), :address => '/profile/{profile}', :icon => 'menu-people'},
      {:name => _('Image gallery'), :address => '/{profile}/gallery', :icon => 'photos'},
      {:name => _('Agenda'), :address => '/profile/{profile}/events', :icon => 'event'},
      {:name => _('Blog'), :address => '/{profile}/blog', :icon => 'edit'},
    ]
    [
      [MainBlock.new],
      [ProfileImageBlock.new(:show_name => true), LinkListBlock.new(:links => links), RecentDocumentsBlock.new],
      [FriendsBlock.new, CommunitiesBlock.new]
    ]
  end

  def default_set_of_articles
    [
      Blog.new(:name => _('Blog')),
      Gallery.new(:name => _('Gallery')),
    ]
  end

  has_and_belongs_to_many :favorite_enterprises, :class_name => 'Enterprise', :join_table => 'favorite_enteprises_people'

  def email_domain
    user && user.email_domain || environment.default_hostname(true)
  end

  def email_addresses
    # TODO for now, only one e-mail address
    ['%s@%s' % [self.identifier, self.email_domain] ]
  end

  def display_info_to?(user)
    if friends.include?(user)
      true
    else
      super
    end
  end

  def default_template
    environment.person_template
  end

  def apply_type_specific_template(template)
    copy_communities_from(template)
  end

  def copy_communities_from(template)
    template.communities.each {|community| community.add_member(self)}
  end


  def self.with_pending_tasks
    Person.find(:all).select{ |person| !person.tasks.pending.empty? or person.has_organization_pending_tasks? }
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
    return false if AddMember.find(:first, :conditions => {:requestor_id => self.id, :target_id => community.id})
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
    profile.members.include?(self)
  end

  def follows?(profile)
    profile.followed_by?(self)
  end

  def each_friend(offset=0)
    while friend = self.friends.first(:order => :id, :offset => offset)
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

  def control_panel_settings_button
    {:title => _('Edit Profile'), :icon => 'edit-profile'}
  end

  def disable
    self.visible = false
    user.password = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{identifier}--")
    user.password_confirmation = user.password
    save!
    user.save!
  end

  def activities
    Scrap.find_by_sql("SELECT id, updated_at, '#{Scrap.to_s}' AS klass FROM #{Scrap.table_name} WHERE scraps.receiver_id = #{self.id} AND scraps.scrap_id IS NULL UNION SELECT id, updated_at, '#{ActionTracker::Record.to_s}' AS klass FROM #{ActionTracker::Record.table_name} WHERE action_tracker.user_id = #{self.id} and action_tracker.verb != 'leave_scrap_to_self' and action_tracker.verb != 'add_member_in_community' ORDER BY updated_at DESC")
  end

  # by default, all fields are private
  def public_fields
    self.fields_privacy.nil? ? [] : self.fields_privacy.reject{ |k, v| v != 'public' }.keys.map(&:to_s)
  end

  protected

  def followed_by?(profile)
    self == profile || self.is_a_friend?(profile)
  end
end
