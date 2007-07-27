class Person < Profile
  belongs_to :user
  has_many :affiliations
  has_many :related_profiles, :class_name => 'Profile', :through => :affiliations
  has_many :friends, :class_name => 'Person'

  def my_enterprises
    related_profiles.select{ |p| p.kind_of?(Enterprise) }
  end
end
