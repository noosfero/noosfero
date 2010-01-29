class AddInviteMembersPermissionToAdmins < ActiveRecord::Migration
  def self.up
    Environment.all.each{ |env|
      admin = Profile::Roles.admin(env.id)
      admin.permissions += ['invite_members']
      admin.save!
    }
  end

  def self.down
    Environment.all.each{ |env|
      admin = Profile::Roles.admin(env.id)
      admin.permissions -= ['invite_members']
      admin.save!
    }
  end
end
