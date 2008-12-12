# A person is the profile of an user holding all relationships with the rest of the system
class Person < Profile

  acts_as_accessor

  has_many :friendships, :dependent => :destroy
  has_many :friends, :class_name => 'Person', :through => :friendships

  has_many :requested_tasks, :class_name => 'Task', :foreign_key => :requestor_id, :dependent => :destroy

  after_destroy do |person|
    Friendship.find(:all, :conditions => { :friend_id => person.id}).each { |friendship| friendship.destroy }
  end

  settings_items :last_lang, :type => :string
  def last_lang
    if self.data[:last_lang].nil? or self.data[:last_lang].empty?
      Noosfero.default_locale
    else
      self.data[:last_lang]
    end
  end

  def suggested_friend_groups
    (friend_groups + [ _('friends'), _('work'), _('school'), _('family') ]).map {|i| i if !i.empty?}.compact.uniq
  end

  def friend_groups
    friendships.map { |item| item.group }.uniq
  end

  def add_friend(friend, group = nil)
    self.friendships.build(:friend => friend, :group => group).save!
  end

  def already_request_friendship?(person)
    person.tasks.find_by_requestor_id(self.id, :conditions => { :type => 'AddFriend' })
  end

  def remove_friend(friend)
    friends.delete(friend)
  end

  FIELDS = %w[
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
  ]

  def self.fields
    FIELDS
  end

  def validate
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
  end

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

  N_('Contact information'); N_('Birth date'); N_('City'); N_('State'); N_('Country'); N_('Sex'); N_('Zip code')
  settings_items :photo, :contact_information, :birth_date, :sex, :city, :state, :country, :zip_code

  def self.conditions_for_profiles(conditions, person)
    new_conditions = sanitize_sql(['role_assignments.accessor_id = ?', person])
    new_conditions << ' AND ' +  sanitize_sql(conditions) unless conditions.blank?
    new_conditions
  end

  def memberships(conditions = {})
    Profile.find(
      :all, 
      :conditions => self.class.conditions_for_profiles(conditions, self), 
      :joins => "LEFT JOIN role_assignments ON profiles.id = role_assignments.resource_id AND role_assignments.resource_type = \'#{Profile.base_class.name}\'",
      :select => 'profiles.*').uniq
  end

  def enterprise_memberships
    memberships(:type => Enterprise.name)
  end

  alias :enterprises :enterprise_memberships

  def community_memberships
    memberships(:type => Community.name)
  end

  alias :communities :community_memberships

  validates_presence_of :user_id
  validates_uniqueness_of :user_id

  def email
    self.user.nil? ? nil : self.user.email
  end

  def email= (email)
    self.user.email = email if ! self.user.nil?
  end

  after_update do |person|
    person.user.save!
  end

  def is_admin?
    role_assignments.map{|ra|ra.role.permissions}.any? do |ps|
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

  def name
    if !self[:name].blank?
      self[:name]
    else
      self.user ? self.user.login : nil
    end
  end

  has_and_belongs_to_many :favorite_enterprises, :class_name => 'Enterprise', :join_table => 'favorite_enteprises_people'

  def email_addresses
    # TODO for now, only one e-mail address
    ['%s@%s' % [self.identifier, self.environment.default_hostname(true) ] ]
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

end
