class AddIpAddressToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :ip_address, :string
    add_column :comments, :spam, :boolean
  end

  def self.down
    remove_column :comments, :ip_address
    remove_column :comments, :spam
  end
end
