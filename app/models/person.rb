# A person is the profile of an user holding all relationships with the rest of the system
class Person < Profile

  acts_as_accessor

  has_many :friendships
  has_many :friends, :class_name => 'Person', :through => :friendships

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

  N_('Contact information'); N_('Birth date'); N_('City'); N_('State'); N_('Country'); N_('Sex');
  settings_items :photo, :contact_information, :birth_date, :sex, :city, :state, :country

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
    ['%s@%s' % [self.identifier, self.environment.default_hostname ] ]
  end

  def display_info_to?(user)
    if friends.include?(user)
      true
    else
      super
    end
  end

end
