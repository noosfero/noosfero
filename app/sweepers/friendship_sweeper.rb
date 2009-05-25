class FriendshipSweeper < ActiveRecord::Observer
  observe :friendship

  def after_create(friendship)
    expire_caches(friendship)
  end

  def after_destroy(friendship)
    expire_cache(friendship.person)
  end

protected

  def expire_caches(friendship)
    expire_cache(friendship.person)
    expire_cache(friendship.friend)
  end

  def expire_cache(profile)
    [profile.friends_cache_key, profile.manage_friends_cache_key].each { |ck|
      cache_key = ck.gsub(/(.)-\d.*$/, '\1')
      expire_timeout_fragment(/#{cache_key}/)
    }

    blocks = profile.blocks.select{|b| b.kind_of?(FriendsBlock)}
    blocks.map(&:cache_keys).each{|ck|expire_timeout_fragment(ck)}
  end

  def expire_fragment(*args)
    ActionController::Base.new().expire_fragment(*args)
  end

  def expire_timeout_fragment(*args)
    ActionController::Base.new().expire_timeout_fragment(*args)
  end
end
