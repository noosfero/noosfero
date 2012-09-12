class AddRedirectionAfterLoginToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :redirection_after_login, :string
  end

  def self.down
    remove_column :profiles, :redirection_after_login
  end
end
