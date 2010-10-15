class AggressiveIndexingStrategy2 < ActiveRecord::Migration
  def self.up
    execute("delete from action_tracker_notifications where id not in (select distinct(atn.id) from action_tracker_notifications as atn JOIN action_tracker_notifications as t ON  (t.profile_id = atn.profile_id and t.action_tracker_id = atn.action_tracker_id and atn.id < t.id))")
    add_index(:action_tracker_notifications, :profile_id)
    add_index(:action_tracker_notifications, :action_tracker_id)
    add_index(:action_tracker_notifications, [:profile_id, :action_tracker_id], :unique => true)
  end

  def self.down
    remove_index(:action_tracker_notifications, :profile_id)
    remove_index(:action_tracker_notifications, :action_tracker_id)
    remove_index(:action_tracker_notifications, [:profile_id, :action_tracker_id])
  end
end
