class AddReferenceToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :profile_id, :integer
  end
  def self.down
    remove_column :roles , :profile_id
  end
end
