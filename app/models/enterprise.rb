#A enterprise is a kind of profile. According to the system concept, only enterprises can offer priducts/services
class Enterprise < ActiveRecord::Base
  
  has_one :enterprise_profile, :class_name => Profile

end
