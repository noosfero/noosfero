# TimedCacheFragment
module ActionController
  module Cache
    module TimedCache
      #handles standard ERB fragments used in RHTML
      def cache_timeout(key={}, expire = 10.minutes.from_now, &block)
        unless perform_caching then block.call; return end
        if is_cache_expired?(key,true)
          expire_timeout_fragment(key)
          set_timeout(key, expire)
        end
        cache_erb_fragment(block,key)
      end
      #handles the expiration of timeout fragment
      def expire_timeout_fragment(key)
        delete_timeout(key)
        expire_fragment(key)
      end
      #checks to see if a cache has fully expired
      def is_cache_expired?(name, is_key = false)
        key = is_key ? name : fragment_cache_key(name)
        return true unless read_fragment(key)
        timeout = get_timeout(key)
        return (!timeout) || (timeout < Time.now)
      end

      # from http://code.google.com/p/timedcachedfragment/issues/detail?id=1
      def cache_erb_fragment(block, name = {}, options = nil)
        unless perform_caching then block.call; return end

        buffer = eval(ActionView::Base.erb_variable, block.binding)

        if cache = read_fragment(name, options)
          buffer.concat(cache)
        else
          pos = buffer.length
          block.call
          write_fragment(name, buffer[pos..-1], options)
        end
      end

      def delete_timeout(key)
        expire_fragment('timeout:' + key)
      end
      def get_timeout(key)
        frag = read_fragment('timeout:' + key)
        frag ? frag.to_time : nil
      end
      def set_timeout(key, value)
        write_fragment('timeout:' + key, value)
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
