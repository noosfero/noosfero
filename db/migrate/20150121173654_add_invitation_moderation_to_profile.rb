class AddInvitationModerationToProfile < ActiveRecord::Migration
  def up
    add_column :profiles, :allow_members_to_invite, :boolean, :default => true
  end

  def down
    remove_column :profiles, :allow_members_to_invite
  end
end
