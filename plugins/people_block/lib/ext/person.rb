require_dependency 'person'

class Person

  scope :with_role, lambda { |role_id|
    { :select => 'DISTINCT profiles.*', :joins => :role_assignments, :conditions => ["role_assignments.role_id = #{role_id}"] }
  }

end
