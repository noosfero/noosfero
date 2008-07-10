class MoreNewPermissions < ActiveRecord::Migration
  def self.up
    admin = Profile::Roles.admin
    admin.permissions += ['moderate_comments']
    admin.save

    moderator = Profile::Roles.moderator
    moderator.permissions += ['moderate_comments']
    moderator.save
  end

  def self.down
    admin = Profile::Roles.admin
    admin.permissions -= ['moderate_comments']
    admin.save

    moderator = Profile::Roles.moderator
    moderator.permissions -= ['moderate_comments']
    moderator.save
  end
end
