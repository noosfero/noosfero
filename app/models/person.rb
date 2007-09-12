# A person is the profile of an user holding all relationships with the rest of the system
class Person < Profile
  ENTERPRISE = {:class_name => 'Enterprise', :through => :affiliations, :foreign_key => 'person_id', :source => 'profile'}

  belongs_to :user
  has_many :affiliations, :dependent => :destroy
  has_many :profiles, :through => :affiliations
  has_many :enterprises,  ENTERPRISE
  has_many :pending_enterprises, ENTERPRISE.merge(:conditions => ['active = ?', false])
  has_many :active_enterprises, ENTERPRISE.merge(:conditions => ['active = ?', true])
  has_many :friendships
  has_many :friends, :class_name => 'Person', :through => :friendships
  has_many :person_friendships
  has_many :people, :through => :person_friendships, :foreign_key => 'friend_id'
  has_one :person_info

  def info
    person_info
  end

  validates_presence_of :user_id

  def initialize(*args)
    super(*args)
    self.person_info ||= PersonInfo.new
  end
end
