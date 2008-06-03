class AddsPasswordTypeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :password_type, :string
  end

  def self.down
    remove_column :users, :password_type
  end
end
