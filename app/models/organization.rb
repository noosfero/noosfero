class Organization < Profile
  has_one :organization_info
  has_many :affiliations
  has_many :people, :through => :affiliations
  has_many :validated_enterprises, :class_name => 'enterprise'
end
