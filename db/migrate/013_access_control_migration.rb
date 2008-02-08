class AccessControlMigration < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name,        :string
      t.column :permissions, :string
      t.column :key,         :string
      t.column :system,      :boolean, :default => false
    end

    create_table :role_assignments do |t|
      t.column :accessor_id,   :integer
      t.column :accessor_type, :string
      t.column :resource_id,   :integer
      t.column :resource_type, :string
      t.column :role_id,       :integer
      t.column :is_global,     :boolean
    end

    # create system-defined roles
    Role.with_scope(:create => { :system => true }) do
      Role.create!(:key => 'profile_admin', :name => N_('Profile Administrator'), :permissions => [
        'edit_profile',
        'destroy_profile',
        'manage_memberships',
        'post_content',
        'edit_profile_design',
        'manage_products',
      ])

      # members for environments, communities etc
      Role.create!(:key => "profile_member", :name => N_('Member'), :permissions => [
        'post_content'
      ])
    end
  end

  def self.down
    drop_table :roles
    drop_table :role_assignments
  end
end
