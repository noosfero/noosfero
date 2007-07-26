#A enterprise is a kind of profile. According to the system concept, only enterprises can offer priducts/services
class Enterprise < ActiveRecord::Base
  
  after_create do |enterprise|
    Profile.create!(:identifier => enterprise.name, :profile_owner_id => enterprise.id, :profile_owner_type => 'Enterprise')
  end
  
  has_one :enterprise_profile, :class_name => 'Profile', :as => :profile_owner
  has_many :users, :through => :affiliation 
  belongs_to :manager, :class_name => 'User'

  validates_presence_of :name, :manager_id
end
