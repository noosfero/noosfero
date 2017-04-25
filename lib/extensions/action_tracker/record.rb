require_relative '../../cache_counter'

class ActionTracker::Record

  extend CacheCounter

  def comments
    type, id = if self.target_type == 'Article' then ['Article', self.target_id] else [self.class.to_s, self.id] end
    Comment.order('created_at ASC').
      where('comments.spam IS NOT TRUE AND comments.reply_of_id IS NULL').
      where('source_type = ? AND source_id = ?', type, id)
  end

  after_create do |record|
    ActionTracker::Record.update_cache_counter(:activities_count, record.user, 1)
    if record.target.kind_of?(Organization)
      ActionTracker::Record.update_cache_counter(:activities_count, record.target, 1)
    end
  end

  has_many :profile_activities, -> {
    where profile_activities: {activity_type: 'ActionTracker::Record'}
  }, foreign_key: :activity_id, dependent: :destroy

  after_create :create_activity
  after_update :update_activity

  after_destroy do |record|
    if record.created_at >= ActionTracker::Record::RECENT_DELAY.days.ago
      ActionTracker::Record.update_cache_counter(:activities_count, record.user, -1)
      if record.target.kind_of?(Organization)
        ActionTracker::Record.update_cache_counter(:activities_count, record.target, -1)
      end
    end
  end

  protected

  def create_activity
    target = if self.target.is_a? Profile then self.target else self.target.profile rescue self.user end
    return if !target
    return if self.verb.in? target.exclude_verbs_on_activities
    ProfileActivity.create! profile: target, activity: self
  end
  def update_activity
    ProfileActivity.update_activity self
  end

end
