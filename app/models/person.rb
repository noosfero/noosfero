# A person is the profile of an user holding all relationships with the rest of the system
class Person < Profile
  belongs_to :user

#  has_many :friendships
#  has_many :friends, :class_name => 'Person', :through => :friendships
#  has_many :person_friendships
#  has_many :people, :through => :person_friendships, :foreign_key => 'friend_id'
  
  has_one :person_info

  has_many :role_assignments
  has_many :memberships, :through => :role_assignments, :source => 'resource', :class_name => 'Enterprise'

  def has_permission?(perm, res=nil)
    role_assignments.any? {|ra| ra.has_permission?(perm, res)}
  end

  def define_roles(roles, resource)
    associations = RoleAssignment.find(:all, :conditions => {:resource_id => resource.id, :resource_type => resource.class.base_class.name, :person_id => self.id })
    roles_add = roles - associations.map(&:role)
    roles_remove = associations.map(&:role) - roles
    associations.each { |a| a.destroy if roles_remove.include?(a.role) }
    roles_add.each {|r| RoleAssignment.create(:person_id => self.id, :resource_id => resource.id, :resource_type => resource.class.base_class.name, :role_id => r.id) }
  end

  def self.conditions_for_profiles(conditions, person)
    new_conditions = sanitize_sql(['role_assignments.person_id = ?', person])
    new_conditions << ' AND ' +  sanitize_sql(conditions) unless conditions.blank?
    new_conditions
  end

  def profiles(conditions = {})
    Profile.find(
      :all, 
      :conditions => self.class.conditions_for_profiles(conditions, self), 
      :joins => "LEFT JOIN role_assignments ON profiles.id = role_assignments.resource_id AND role_assignments.resource_type = \"#{Profile.base_class.name}\"",
      :select => 'profiles.*')
  end

  
  def enterprises(conditions = {})
    profiles( ({:type => 'Enterprise'}).merge(conditions))
  end

  def pending_enterprises
    enterprises :active => false
  end

  def active_enterprises
    enterprises :active => true
  end

  def info
    person_info
  end

  validates_presence_of :user_id

  def initialize(*args)
    super(*args)
    self.person_info ||= PersonInfo.new
    self.person_info.person = self
  end
end
