class ChangeColumnRolesPermissonsToText < ActiveRecord::Migration
  def self.up
    change_column :roles, :permissions, :text
  end

  def self.down
    change_column :roles, :permissions, :string
  end
end
