module CacheCounterHelper
  def update_cache_counter(name, object, value)
    if object.present?
      object.send(name.to_s+'=', object.send(name) + value)
      object.save!
    end
  end
end
