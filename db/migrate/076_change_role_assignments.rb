class ChangeRoleAssignments < ActiveRecord::Migration
  def self.up
    execute 'DELETE FROM role_assignments WHERE role_id NOT IN (SELECT id FROM roles)'

    change_column :role_assignments, :accessor_id, :integer, :null => false
    change_column :role_assignments, :role_id,     :integer, :null => false
  end

  def self.down
    change_column :role_assignments, :accessor_id, :integer, :null => true
    change_column :role_assignments, :role_id,     :integer, :null => true
  end
end
