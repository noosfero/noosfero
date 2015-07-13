class AddCustomRolesPermissionToAdminRoles < ActiveRecord::Migration
  def self.up
    environment_admin = Role.find_by_key("environment_administrator")
    profile_admin = Role.find_by_key("profile_admin")
    environment_admin.permissions.append("manage_custom_roles")
    profile_admin.permissions.append("manage_custom_roles")
    environment_admin.save!
    profile_admin.save!
  end
  def self.down
    environment_admin = Role.find_by_key("environment_administrator")
    profile_admin = Role.find_by_key("profile_admin")
    environment_admin.permissions.delete("manage_custom_roles")
    profile_admin.permissions.delete("manage_custom_roles")
    environment_admin.save!
    profile_admin.save!
  end
end
