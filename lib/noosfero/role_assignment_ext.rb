Rails.configuration.to_prepare do
  RoleAssignment.module_eval do
    extend CacheCounterHelper

    after_create do |role_assignment|
      accessor = role_assignment.accessor
      resource = role_assignment.resource
      if resource.kind_of?(Organization)
        #FIXME This will only work as long as the role_assignment associations
        #happen only between profiles, due to the polymorphic column type.
        if resource.role_assignments.where(:accessor_id => accessor.id).count == 1
          RoleAssignment.update_cache_counter(:members_count, resource, 1)
        end
      end
    end

    after_destroy do |role_assignment|
      accessor = role_assignment.accessor
      resource = role_assignment.resource
      if resource.kind_of?(Organization)
        #FIXME This will only work as long as the role_assignment associations
        #happen only between profiles, due to the polymorphic column type.
        if resource.role_assignments.where(:accessor_id => accessor.id).count == 0
          RoleAssignment.update_cache_counter(:members_count, resource, -1)
        end
      end
    end
  end
end
