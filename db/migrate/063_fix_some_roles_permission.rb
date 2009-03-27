class FixSomeRolesPermission < ActiveRecord::Migration
  def self.up
    admin = Profile::Roles.admin
    admin.permissions += ['view_private_content']
    admin.save

    moderator = Profile::Roles.moderator
    moderator.permissions += ['view_private_content']
    moderator.save
  end

  def self.down
    admin = Profile::Roles.admin
    admin.permissions -= ['view_private_content']
    admin.save

    moderator = Profile::Roles.moderator
    moderator.permissions -= ['view_private_content']
    moderator.save
  end
end
