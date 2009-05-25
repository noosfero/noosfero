# TimedCacheFragment
module ActionController
  module Cache
    module TimedCache
      #used to store the associated timeout time of cache key
      @@cache_timeout_values = {}
      #handles standard ERB fragments used in RHTML
      def cache_timeout(name={}, expire = 10.minutes.from_now, &block)
        unless perform_caching then block.call; return end
        key = fragment_cache_key(name)
        if is_cache_expired?(key,true)
          expire_timeout_fragment(key)
          @@cache_timeout_values[key] = expire
        end
        cache_erb_fragment(block,name)
      end
      #handles the expiration of timeout fragment
      def expire_timeout_fragment(key)
        @@cache_timeout_values.keys.select{|k| key === k}.each do |k|
          @@cache_timeout_values[k] = nil
        end
        expire_fragment(/#{key}/)
      end
      #checks to see if a cache has fully expired
      def is_cache_expired?(name, is_key = false)
        key = is_key ? name : fragment_cache_key(name)
        return (!@@cache_timeout_values[key]) || (@@cache_timeout_values[key] < Time.now)
      end
    end
  end
end


module ActionView
  module Helpers
    module TimedCacheHelper
      def is_cache_expired?(name = nil)
        return false if name.nil?
        key = fragment_cache_key(name)
        return @controller.send('is_cache_expired?', key)
      end
      def cache_timeout(name,expire=10.minutes.from_now, &block)
        @controller.cache_timeout(name,expire,&block)
      end
    end
  end
end

#add to the respective controllers
ActionView::Base.send(:include, ActionView::Helpers::TimedCacheHelper)
ActionController::Base.send(:include, ActionController::Cache::TimedCache)
