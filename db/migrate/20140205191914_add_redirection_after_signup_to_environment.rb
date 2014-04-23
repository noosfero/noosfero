class AddRedirectionAfterSignupToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :redirection_after_signup, :string, :default => 'keep_on_same_page'
  end

  def self.down
    remove_column :environments, :redirection_after_signup
  end
end
