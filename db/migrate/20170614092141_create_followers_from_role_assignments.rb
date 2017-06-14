class CreateFollowersFromRoleAssignments < ActiveRecord::Migration
  def up
    # Create memberships curcle if it not exists
    execute("INSERT INTO circles(name, person_id, profile_type) "\
            "SELECT DISTINCT 'memberships', ra.accessor_id, 'Community'"\
            "FROM role_assignments as ra "\
            "JOIN profiles ON ra.resource_id = profiles.id "\
            "WHERE ra.resource_type = 'Profile' "\
              "AND profiles.type = 'Community' "\
              "AND NOT EXISTS ("\
                "SELECT id FROM circles as pc "\
                "WHERE pc.person_id = ra.accessor_id "\
                  "AND pc.profile_type = 'Community' "\
                  "AND pc.name = 'memberships')")

    # Add follower relationships if it does not exist for some members
    execute("INSERT INTO profiles_circles(profile_id, circle_id) "\
            "SELECT DISTINCT ra.resource_id, c.id "\
              "FROM role_assignments as ra "\
              "JOIN profiles ON ra.resource_id = profiles.id "\
              "JOIN circles as c ON ra.accessor_id = c.person_id "\
              "WHERE ra.resource_type = 'Profile' "\
                "AND profiles.type = 'Community' "\
                "AND c.name = 'memberships' "\
                "AND NOT EXISTS ("\
                  "SELECT id FROM profiles_circles as pc "\
                  "WHERE pc.profile_id = ra.resource_id "\
                    "AND pc.circle_id = c.id)")
  end

  def down
    say 'This migration cannot be reverted'
  end
end
