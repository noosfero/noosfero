Rails.configuration.to_prepare do
  ActionTracker::Record.class_eval do
    extend CacheCounterHelper

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
end
