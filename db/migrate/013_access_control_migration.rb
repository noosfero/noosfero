class AccessControlMigration < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name,        :string
      t.column :permissions, :string
    end

    create_table :role_assignments do |t|
      t.column :accessor_id,   :integer
      t.column :accessor_type, :string
      t.column :resource_id,   :integer
      t.column :resource_type, :string
      t.column :role_id,       :integer
    end
  end

  def self.down
    drop_table :roles
    drop_table :role_assignments
  end
end
