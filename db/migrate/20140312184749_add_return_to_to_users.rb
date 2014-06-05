class AddReturnToToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :return_to, :string
  end

  def self.down
    remove_column :users, :return_to, :string
  end
end
