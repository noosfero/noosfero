Rails.configuration.to_prepare do
  ActionTracker::Record.module_eval do
    extend CacheCounterHelper

    after_create do |record|
      ActionTracker::Record.update_cache_counter(:activities_count, record.user, 1)
      if record.target.kind_of?(Organization)
        ActionTracker::Record.update_cache_counter(:activities_count, record.target, 1)
      end
    end

    after_destroy do |record|
      if record.created_at >= ActionTracker::Record::RECENT_DELAY.days.ago
        ActionTracker::Record.update_cache_counter(:activities_count, record.user, -1)
        if record.target.kind_of?(Organization)
          ActionTracker::Record.update_cache_counter(:activities_count, record.target, -1)
        end
      end
    end
  end
end
