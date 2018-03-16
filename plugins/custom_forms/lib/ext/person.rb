require_dependency 'person'

class Person
  def can_see_summary?(profile)
    (self == profile) || is_admin? || profile.admins.include?(self)
  end
end
