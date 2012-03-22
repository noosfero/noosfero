require_dependency 'person'

class Person
  validates_uniqueness_of :usp_id
end
