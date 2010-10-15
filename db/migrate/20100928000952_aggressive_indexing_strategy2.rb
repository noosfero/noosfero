class AggressiveIndexingStrategy2 < ActiveRecord::Migration
  def self.up

    say 'Removing duplicate notification records ...'
    buffer = ''
    removed = 0
    select_all(
      'select min(id) as min_id, action_tracker_id, profile_id, count(*)
      from action_tracker_notifications
      group by action_tracker_id, profile_id
      having count(*) > 1'
    ).each do |duplicate|
      buffer += ('delete from action_tracker_notifications
        where
          profile_id = %d AND
          action_tracker_id = %s AND
        id > %d;
        ' % [duplicate['profile_id'], duplicate['action_tracker_id'], duplicate['min_id']]
      )
      if removed % 100 == 0
        execute buffer
        say "Deleted " + removed.to_s
        buffer = ''
      end
      removed += 1
    end

    if !buffer.empty?
      execute buffer
    end

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
