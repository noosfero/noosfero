class AddNicknameToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :nickname, :string, :null => true, :limit => 16
  end

  def self.down
    remove_column :profiles, :nickname
  end
end
