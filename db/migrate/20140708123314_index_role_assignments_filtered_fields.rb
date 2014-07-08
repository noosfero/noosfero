class IndexRoleAssignmentsFilteredFields < ActiveRecord::Migration

  def self.up
    add_index :role_assignments, [:accessor_id, :accessor_type]
    add_index :role_assignments, [:accessor_id, :accessor_type, :role_id]
    add_index :role_assignments, [:resource_id, :resource_type]
    add_index :role_assignments, [:resource_id, :resource_type, :role_id]
    add_index :role_assignments, [:accessor_id, :accessor_type, :resource_id, :resource_type]
    add_index :profiles, [:type]
    add_index :profiles, [:visible]
    add_index :profiles, [:enabled]
    add_index :profiles, [:validated]
  end

end
