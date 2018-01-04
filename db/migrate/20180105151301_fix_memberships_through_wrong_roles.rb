class FixMembershipsThroughWrongRoles < ActiveRecord::Migration
  def change
    Community.find_each do |group|
      m1 = group.members
      m2 = group.members.by_role(Profile::Roles.organization_member_and_custom_roles(group.environment.id, group.id))
      m3 = m1 - m2
      if m3.present?
        m3.each do |member|
          group.remove_member(member)
          group.add_member(member)
        end
      end
    end
  end
end
