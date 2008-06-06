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

      # Environment administrator!
      Role.create!(:key => 'environment_administrator', :name => N_('Environment Administrator'), :permissions => [
        'view_environment_admin_panel',
        'edit_environment_features', 
        'edit_environment_design', 
        'manage_environment_categories', 
        'manage_environment_roles', 
        'manage_environment_validators'
      ])

      Role.create!(:key => 'profile_admin', :name => N_('Profile Administrator'), :permissions => [
        'edit_profile',
        'destroy_profile',
        'manage_memberships',
        'post_content',
        'edit_profile_design',
        'manage_products',
      ])

      # members for enterprises, communities etc
      Role.create!(:key => "profile_member", :name => N_('Member'), :permissions => [
        'edit_profile', 
        'post_content', 
        'manage_products' 
      ])

      # moderators for enterprises, communities etc
      Role.create!(:key => 'profile_moderator', :name => N_('Moderator'), :permissions => [
        'manage_memberships', 
        'edit_profile_design', 
        'manage_products'
      ])

    end
  end

  def self.down
    drop_table :roles
    drop_table :role_assignments
  end
end
