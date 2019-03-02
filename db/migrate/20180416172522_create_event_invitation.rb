class CreateEventInvitation < ActiveRecord::Migration[5.1]

  def self.up
    create_table :event_invitations do |t|
      t.column :event_id,      :integer
      t.column :guest_id,      :integer
      t.column :requestor_id,  :integer
      t.column :decision,      :integer
    end
  end

  def self.down
    drop_table :event_invitations
  end
end
