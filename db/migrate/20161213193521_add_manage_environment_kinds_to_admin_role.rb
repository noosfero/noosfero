class AddManageEnvironmentKindsToAdminRole < ActiveRecord::Migration[4.2]
  def self.up
    Environment.all.map(&:id).each do |id|
      role = Environment::Roles.admin(id)
      role.permissions << "manage_environment_kinds"
      role.save!
    end
  end

  def self.down
    Environment.all.map(&:id).each do |id|
      role = Environment::Roles.admin(id)
      role.permissions -= ["manage_environment_kinds"]
      role.save!
    end
  end
end
