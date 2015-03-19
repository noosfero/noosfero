class AddTimestampsToRoleAssignments < ActiveRecord::Migration
  def change
    add_timestamps :role_assignments
  end
end
