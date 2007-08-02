class Organization < Profile
  has_one :organization_info
  has_many :affiliations
  has_many :people, :through => :affiliations
end
