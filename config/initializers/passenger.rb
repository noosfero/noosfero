if defined? PhusionPassenger

  # from http://russbrooks.com/2010/10/20/rails-cache-memcache-on-passenger-with-smart-spawning
  PhusionPassenger.on_event :starting_worker_process do |forked|
    if forked
      Rails.cache.instance_variable_get(:@data).reset if Rails.cache.class.name == 'ActiveSupport::Cache::MemCacheStore'
    end
  end
end
