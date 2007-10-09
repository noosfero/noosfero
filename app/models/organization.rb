# Represents any organization of the system and has an organization_info object to hold its info
class Organization < Profile
  has_one :organization_info
  has_many :validated_enterprises, :class_name => 'enterprise'

#  def info
#    organization_info
#  end

#  def info=(infos)
#    organization_info.update_attributes(infos)
#  end
end
