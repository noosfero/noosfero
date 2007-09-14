class CreateRoleAssignments < ActiveRecord::Migration
  def self.up
    create_table :role_assignments do |t|
      t.column :person_id,      :integer
      t.column :role_id,        :integer
      t.column :resource_id,    :integer
      t.column :resource_type,  :string
    end
  end

  def self.down
    drop_table :role_assignments
  end
end
