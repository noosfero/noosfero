class ActiveRecord::Base
  # This is the global hash of permissions and each item is of the form 
  # 'class_name' => permission_hash for each target have its own set of permissions
  # but its not a namespace so each permission name should be unique
  PERMISSIONS = {}
  
  # Acts as accessible makes a model acts as a resource that can be targeted by a permission
  def self.acts_as_accessible
    has_many :role_assignments, :as => :resource
    
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
      roles.map {|role| accessor.remove_role(role, self)}.any? 
    end

    def members
      role_assignments.map(&:accessor).uniq
    end
  end
end
