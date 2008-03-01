class NewPermissions < ActiveRecord::Migration
  def self.up
    admin = Profile::Roles.admin
    admin.permissions += ['manage_friends', 'validate_enterprise', 'peform_task']
    admin.save

    moderator = Profile::Roles.moderator
    moderator.permissions += ['manage_friends', 'peform_task']
    moderator.save
  end

  def self.down
    admin = Profile::Roles.admin
    admin.permissions -= ['manage_friends', 'validate_enterprise', 'peform_task']
    admin.save

    moderator = Profile::Roles.moderator
    moderator.permissions -= ['manage_friends', 'peform_task']
    moderator.save
  end
end
