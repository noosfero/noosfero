module CacheCounterHelper
  def update_cache_counter(name, object, value)
    if object.present?
      object.class.update_counters(object.id, name => value)
    end
  end
end
