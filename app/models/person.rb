class Person < Profile
  ENTERPRISE = {:class_name => 'Enterprise', :through => :affiliations, :source => 'organization'}

  belongs_to :user
  has_many :affiliations
  has_many :organizations, :through => :affiliations
  has_many :enterprises,  ENTERPRISE
  has_many :pending_enterprises, ENTERPRISE.merge(:conditions => ['active = ?', false])
  has_many :active_enterprises, ENTERPRISE.merge(:conditions => ['active = ?', true])
  has_many :friendships
  has_many :friends, :class_name => 'Person', :through => :friendships
  has_many :person_friendships
  has_many :people, :through => :person_friendships, :foreign_key => 'friend_id'
end
