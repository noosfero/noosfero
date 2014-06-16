module ActsAsAccessible
  # This is the global hash of permissions and each item is of the form 
  # 'class_name' => permission_hash for each target have its own set of permissions
  # but its not a namespace so each permission name should be unique
  PERMISSIONS = {}

  extend ActiveSupport::Concern

  module ClassMethods
    # Acts as accessible makes a model acts as a resource that can be targeted by a permission
    def acts_as_accessible
      has_many :role_assignments, :as => :resource, :dependent => :destroy
    end
  end

  # A superior instance is an object that has higher level an thus can be targeted by a permission
  # to represent an permission over a group of related resources rather than a single one
  def superior_instance
    nil
  end

  def affiliate(accessor, roles)
    roles = [roles] unless roles.kind_of?(Array)
    roles.map {|role| accessor.add_role(role, self)}.any? 
  end

  def disaffiliate(accessor, roles)
    roles = [roles] unless roles.kind_of?(Array)
    role_assignments.map{|ra|ra.destroy if roles.include?(ra.role) && ra.accessor == accessor} 
  end

  def roles
    Role.find_all_by_environment_id(environment.id).select do |r| 
      r.permissions.any?{ |p| PERMISSIONS[self.class.base_class.name].include?(p) }
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsAccessible)
