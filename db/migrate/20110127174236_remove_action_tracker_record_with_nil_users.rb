class RemoveActionTrackerRecordWithNilUsers < ActiveRecord::Migration
  def self.up
    ActionTracker::Record.all.map {|record| record.destroy if record.user.nil?}
  end

  def self.down
    say "this migration can't be reverted"
  end
end
