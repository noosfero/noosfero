class AddUpdatedAtToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :updated_at, :datetime
    execute 'update profiles set updated_at = created_at'
  end

  def self.down
    remove_column :profiles, :updated_at
  end
end
