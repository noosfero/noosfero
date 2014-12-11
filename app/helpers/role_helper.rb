module RoleHelper

  def role_available_permissions(role)
    role.kind == "Environment" ? ['Environment', 'Profile'] : [role.kind]
  end

end
