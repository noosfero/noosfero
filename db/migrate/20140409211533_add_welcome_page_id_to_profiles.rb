class AddWelcomePageIdToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :welcome_page_id, :integer
  end

  def self.down
    remove_column :profiles, :welcome_page_id
  end
end
