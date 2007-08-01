class Person < Profile
  belongs_to :user
  has_many :personal_affiliations, :class_name => 'Affiliation'
  has_many :related_profiles, :class_name => 'Profile', :through => :personal_affiliations, :source => 'profile'

  has_many :enterprises, :class_name => 'Enterprise', :through => :personal_affiliations, :source => 'profile', :conditions => ['active = ?', true]
 
  has_many :pending_enterprises, :class_name => 'Profile', :through => :personal_affiliations, :source => 'profile', :conditions => ['type = ? and active = ?', 'Enterprise', false]
  
  has_many :friendships
  has_many :friends, :class_name => 'Person', :through => :friendships

  has_many :other_friendships
  has_many :other_friend, :class_name => 'Person', :through => :other_friendships, :foreign_key => 'friend_id'
end
