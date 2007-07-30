class Person < Profile
  belongs_to :user
  has_many :personal_affiliations, :class_name => 'Affiliation'
  has_many :related_profiles, :class_name => 'Profile', :through => :personal_affiliations, :source => 'profile'

  has_many :friendships
  has_many :friends, :class_name => 'Person', :through => :friendships

  has_many :other_friendships
  has_many :other_friend, :class_name => 'Person', :through => :other_friendships, :foreign_key => 'friend_id'

  def my_enterprises(status = true)
    related_profiles.find(:all, :conditions => ['type = ? and active = ?', 'Enterprise', status])
  end
end
