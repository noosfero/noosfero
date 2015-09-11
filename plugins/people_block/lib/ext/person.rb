require_dependency 'person'

class Person

  scope :with_role, -> role_id {
    select('DISTINCT profiles.*').joins(:role_assignments).
    where("role_assignments.role_id = #{role_id}")
  }

end
