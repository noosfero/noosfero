class RemoveUselessTrackedActions < ActiveRecord::Migration
  def self.up
    select_all("SELECT id FROM action_tracker WHERE verb IN ('update_article', 'remove_article', 'leave_comment', 'leave_community', 'remove_member_in_community')").each do |tracker|
      activity = ActionTracker::Record.find_by_id(tracker['id'])
      activity.destroy if activity
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
