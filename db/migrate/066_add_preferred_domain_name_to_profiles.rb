class AddPreferredDomainNameToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :preferred_domain_id, :integer
  end

  def self.down
    remove_column :profiles, :preferred_domain_id
  end
end
