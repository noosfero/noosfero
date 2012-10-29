class AddSignupWelcomeText < ActiveRecord::Migration
  def self.up
    add_column :environments, :signup_welcome_text, :text
  end

  def self.down
    remove_column :environments, :signup_welcome_text
  end
end
