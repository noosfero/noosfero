class FixesTrackedNotificationsReceiverInfo < ActiveRecord::Migration
  def up
    ActionTracker::Record.where(verb: 'reply_scrap_on_self').find_each do |n|
      if n.target
        n.params['receiver_name'] ||= n.target.receiver.name
        n.params['receiver_url'] ||= n.target.receiver.url
        n.save
      end
    end
  end

  def down
    say "This migration can't be reverted"
  end
end
