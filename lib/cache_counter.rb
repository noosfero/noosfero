# FIXME: this is placed on lib due to extensions
module CacheCounter

  def update_cache_counter(name, object, value)
    if object.present?
      object.class.update_counters(object.id, name => value)
    end
  end

end
