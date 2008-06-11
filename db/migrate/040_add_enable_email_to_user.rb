class AddEnableEmailToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :enable_email, :boolean, :default => false
  end

  def self.down
    remove_column :users, :enable_email
  end
end
