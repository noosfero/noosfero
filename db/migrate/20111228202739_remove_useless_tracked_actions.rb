class RemoveUselessTrackedActions < ActiveRecord::Migration
  def self.up
    select_all("SELECT id FROM action_tracker").each do |tracker|
      verbs = ['update_article', 'remove_article', 'leave_comment', 'leave_community', 'remove_member_in_community']
      activity = ActionTracker::Record.find_by(id: tracker['id'])
      if activity
        if (activity.updated_at.to_time < Time.now.months_ago(3)) || verbs.include?(activity.verb)
          activity.destroy
        end
      end
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
