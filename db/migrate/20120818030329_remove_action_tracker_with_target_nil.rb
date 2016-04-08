class RemoveActionTrackerWithTargetNil < ActiveRecord::Migration
  def self.up
    select_all("SELECT id FROM action_tracker").each do |tracker|
      activity = ActionTracker::Record.find_by(id: tracker['id'])
      if activity && activity.target.nil?
        activity.destroy
      end
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
