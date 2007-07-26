#A enterprise is a kind of profile. According to the system concept, only enterprises can offer priducts/services
class Enterprise < ActiveRecord::Base
  
  after_create do |enterprise|
    enterprise_profile = Profile.create(:identifier => enterprise.name)  
  end
  
  has_one :enterprise_profile, :class_name => 'Profile', :as => :profile_owner
   
  def name=(a_name)
    enterprise_profile.name = a_name
  end

  def name
    enterprise_profile.name
  end

end
