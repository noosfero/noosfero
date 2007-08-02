class Organization < Profile
  has_one :organization_info
  has_many :validated_enterprises, :class_name => 'enterprise'
end
