class Role < ActiveRecord::Base; end
class RoleWithEnvironment < ActiveRecord::Base
  self.table_name = 'roles'
  belongs_to :environment
end
class RoleAssignment < ActiveRecord::Base
  belongs_to :accessor, :polymorphic => true
  belongs_to :resource, :polymorphic => true
end

class AddEnviromentIdToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :environment_id, :integer

    roles = Role.find(:all)
    Environment.find(:all).each do |env|
      roles.each do |role|
        re = RoleWithEnvironment.new(role.attributes)
        re.environment = env
        re.save
        RoleAssignment.find_all_by_role_id(role.id).select{|ra| ra.resource && (ra.resource.kind_of?(Profile) ? ra.resource.environment_id : ra.resource.id) == env.id }.each do |ra|
          ra.role_id = re.id
          ra.save
        end
      end
    end
    roles.each(&:destroy)
  end

  def self.down
    roles_by_name = {}
    roles_by_key = {}
    roles_with_environment = RoleWithEnvironment.find(:all)
    roles_with_environment.each do |re|
      if re.key
        role = roles_by_name[re.key] || roles_by_key[re.name] || Role.create(re.attributes)
        roles_by_name[role.name] ||= roles_by_key[role.key] ||= role
      end
      role = roles_by_name[re.name] ||= Role.create(re.attributes) unless role
      RoleAssignment.find_all_by_role_id(re.id).each do |ra|
        ra.role_id = role.id
        ra.save
      end
    end
    roles_with_environment.each(&:destroy)

    remove_column :roles, :environment_id, :integer
  end
end
