class ProfileActivity < ApplicationRecord

  self.record_timestamps = false

  attr_accessible :profile_id,
    :profile, :activity

  belongs_to :profile
  belongs_to :activity, polymorphic: true

  # non polymorphic versions
  belongs_to :scrap, -> {
    where profile_activities: {activity_type: 'Scrap'}
  }, foreign_key: :activity_id, class_name: 'Scrap'
  belongs_to :action_tracker, -> {
    where profile_activities: {activity_type: 'ActionTracker::Record'}
  }, foreign_key: :activity_id, class_name: 'ActionTracker::Record'

  before_validation :copy_timestamps

  def self.update_activity activity
    profile_activity = ProfileActivity.where(activity_id: activity.id, activity_type: activity.class.base_class.name).first
    return unless profile_activity
    profile_activity.send :copy_timestamps
    profile_activity.save!
    profile_activity
  end

  protected

  def copy_timestamps
    self.created_at = self.activity.created_at if self.activity.created_at
    self.updated_at = self.activity.updated_at if self.activity.updated_at
  end

end
