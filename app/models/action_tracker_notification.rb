class ActionTrackerNotification < ApplicationRecord

  belongs_to :profile
  belongs_to :action_tracker, :class_name => 'ActionTracker::Record', :foreign_key => 'action_tracker_id'

  delegate :comments, :to => :action_tracker, :allow_nil => true

  validates_presence_of :profile_id, :action_tracker_id
  validates_uniqueness_of :action_tracker_id, :scope => :profile_id

  attr_accessible :profile_id, :action_tracker_id

end

ActionTracker::Record.has_many :action_tracker_notifications, :class_name => 'ActionTrackerNotification', :foreign_key => 'action_tracker_id', :dependent => :destroy
