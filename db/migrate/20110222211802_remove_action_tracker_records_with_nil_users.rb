class RemoveActionTrackerRecordsWithNilUsers < ActiveRecord::Migration
  # This migration is a copy of 20110127174236_remove_action_tracker_record_with_nil_users.rb
  def self.up
    ActionTracker::Record.all.map {|record| record.destroy if record.user.nil?}
  end

  def self.down
    say "this migration can't be reverted"
  end
end
