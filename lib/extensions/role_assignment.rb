require_relative '../cache_counter'

class RoleAssignment

  extend CacheCounter

  FOLLOWER_ROLE_KEYS = [
    'profile_admin',
    'profile_member'
  ]

  after_create do |role_assignment|
    accessor = role_assignment.accessor
    resource = role_assignment.resource
    if resource.kind_of?(Organization)
      #FIXME This will only work as long as the role_assignment associations
      #happen only between profiles, due to the polymorphic column type.
      if resource.role_assignments.where(:accessor_id => accessor.id).count == 1
        RoleAssignment.update_cache_counter(:members_count, resource, 1)
      end

      if accessor.kind_of?(Person) && role_assignment.role.key.in?(FOLLOWER_ROLE_KEYS)
        circle = Circle.find_or_create_by(
          :person => accessor,
          :name =>_('memberships'),
          :profile_type => resource.class.name
        )
        accessor.follow(resource, circle)
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

      if accessor.kind_of?(Person) && role_assignment.role.key.in?(FOLLOWER_ROLE_KEYS)
        # Unfollow the profile if the accessor doesn't have more roles in the resource
        assignments = accessor.role_assignments.where(resource: resource)
        accessor.unfollow(resource) if assignments.count == 0
      end
    end
  end

end
