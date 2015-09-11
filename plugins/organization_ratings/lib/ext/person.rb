require_dependency 'person'

Person.class_eval do
  has_many :organization_ratings
end
