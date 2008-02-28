class NewPermissions < ActiveRecord::Migration
  def self.up
    admin = Role.find_by_key('profile_admin')
    admin.permissions += ['manage_friends', 'validate_enterprise', 'peform_task']
    admin.save

    moderator = Role.find_by_key('profile_moderator')
    moderator.permissions += ['manage_friends', 'peform_task']
    moderator.save
  end

  def self.down
    admin = Role.find_by_key('profile_admin')
    admin.permissions -= ['manage_friends', 'validate_enterprise', 'peform_task']
    admin.save

    moderator = Role.find_by_key('profile_moderator')
    moderator.permissions -= ['manage_friends', 'peform_task']
    moderator.save
  end
end
