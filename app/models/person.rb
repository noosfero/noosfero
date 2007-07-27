class Person < Profile
  belongs_to :user
  has_many :affiliations
  has_many :profiles, :through => :affiliations
  has_many :friends, :class_name => 'Person'
end
