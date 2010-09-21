# A person is the profile of an user holding all relationships with the rest of the system
class Person < Profile

  acts_as_trackable :after_add => Proc.new {|p,t| notify_activity(t)}
  acts_as_accessor

  named_scope :members_of, lambda { |resource| { :select => 'DISTINCT profiles.*', :joins => :role_assignments, :conditions => ['role_assignments.resource_type = ? AND role_assignments.resource_id = ?', resource.class.base_class.name, resource.id ] } }

  def memberships
    Profile.memberships_of(self)
  end

  has_many :friendships, :dependent => :destroy
  has_many :friends, :class_name => 'Person', :through => :friendships

  has_many :requested_tasks, :class_name => 'Task', :foreign_key => :requestor_id, :dependent => :destroy

  has_many :mailings

  has_many :scraps_received, :class_name => 'Scrap', :foreign_key => :receiver_id, :order => "updated_at DESC"
  has_many :scraps_sent, :class_name => 'Scrap', :foreign_key => :sender_id

  named_scope :more_popular,
       :select => "#{Profile.qualified_column_names}, count(friend_id) as total",
       :group => Profile.qualified_column_names,
       :joins => :friendships,
       :order => "total DESC"

  after_destroy do |person|
    Friendship.find(:all, :conditions => { :friend_id => person.id}).each { |friendship| friendship.destroy }
  end

  after_destroy :destroy_user
  def destroy_user
    self.user.destroy if self.user
  end

  def scraps(scrap=nil)
    scrap = scrap.is_a?(Scrap) ? scrap.id : scrap
    scrap.nil? ? Scrap.all_scraps(self) : Scrap.all_scraps(self).find(scrap)
  end

  def can_control_scrap?(scrap)
    begin
      !self.scraps(scrap).nil?
    rescue
      false
    end
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
  ]

  def self.fields
    FIELDS
  end

  def validate
    super
    self.required_fields.each do |field|
      if self.send(field).blank?
        unless (field == 'custom_area_of_study' && self.area_of_study != 'Others') || (field == 'custom_formation' && self.formation != 'Others')
          self.errors.add(field, _('%{fn} is mandatory'))
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
    environment ? environment.active_person_fields : []
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

  N_('Formation'); N_('Custom formation'); N_('Custom area of study');
  settings_items :formation, :custom_formation, :custom_area_of_study

  N_('Contact information'); N_('City'); N_('State'); N_('Country'); N_('Sex'); N_('Zip code')
  settings_items :photo, :contact_information, :sex, :city, :state, :country, :zip_code

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
      record.errors.add(attr, _('%{fn} is already used by other user'))
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

  def is_admin?(environment)
    role_assignments.select { |ra| ra.resource == environment }.map{|ra|ra.role.permissions}.any? do |ps|
      ps.any? do |p|
        ActiveRecord::Base::PERMISSIONS['Environment'].keys.include?(p)
      end
    end
  end

  def default_set_of_blocks
    [
      [MainBlock],
      [ProfileInfoBlock, RecentDocumentsBlock, TagsBlock],
      [FriendsBlock, EnterprisesBlock, CommunitiesBlock]
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

  def template
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

  protected

  def followed_by?(profile)
    self == profile || self.is_a_friend?(profile)
  end

end
