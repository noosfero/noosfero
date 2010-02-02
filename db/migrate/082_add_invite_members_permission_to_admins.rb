class AddInviteMembersPermissionToAdmins < ActiveRecord::Migration
  def self.up
    select_all("SELECT * from roles where key = 'profile_admin'").each do |role|
      permissions = (YAML.load(role['permissions']) + ['invite_members']).to_yaml
      role_id = role['id']
      update("update roles set permissions = '%s' where id = %d" % [permissions, role_id])
    end
  end

  def self.down
    select_all("SELECT * from roles where key = 'profile_admin'").each do |role|
      permissions = (YAML.load(role['permissions']) - ['invite_members']).to_yaml
      role_id = role['id']
      update("update roles set permissions = '%s' where id = %d" % [permissions, role_id])
    end
  end
end
