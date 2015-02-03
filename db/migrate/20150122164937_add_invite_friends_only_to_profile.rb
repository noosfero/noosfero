class AddInviteFriendsOnlyToProfile < ActiveRecord::Migration
  def up
    add_column :profiles, :invite_friends_only, :boolean, :default => false
  end

  def down
    remove_column :profiles, :invite_friends_only
  end
end
