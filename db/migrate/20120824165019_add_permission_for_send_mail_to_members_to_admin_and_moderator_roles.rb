class AddPermissionForSendMailToMembersToAdminAndModeratorRoles < ActiveRecord::Migration
  def self.up
    Environment.all.map(&:id).each do |id|
      role = Profile::Roles.admin(id)
      role.permissions += ['send_mail_to_members']
      role.save!
      role = Profile::Roles.moderator(id)
      role.permissions += ['send_mail_to_members']
      role.save!
    end
  end

  def self.down
    Environment.all.map(&:id).each do |id|
      role = Profile::Roles.admin(id)
      role.permissions -= ['send_mail_to_members']
      role.save!
      role = Profile::Roles.moderator(id)
      role.permissions -= ['send_mail_to_members']
      role.save!
    end
  end
end
