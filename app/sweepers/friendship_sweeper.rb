class FriendshipSweeper < ActiveRecord::Observer
  observe :friendship
  include SweeperHelper

  def after_create(friendship)
    expire_caches(friendship)
  end

  def after_destroy(friendship)
    expire_cache(friendship.person)
  end

protected

  def expire_caches(friendship)
    [friendship.person, friendship.friend].each do |profile|
      if profile
        expire_cache(profile)
      end
    end
  end

  def expire_cache(profile)
    # public friends page
    pages =  profile.friends.count / Noosfero::Constants::PROFILE_PER_PAGE + 1
    (1..pages).each do |i|
      expire_timeout_fragment(profile.friends_cache_key(:npage => i.to_s))
    end
    # manage friends page
    pages =  profile.friends.count / Noosfero::Constants::PROFILE_PER_PAGE + 1
    (1..pages).each do |i|
      expire_timeout_fragment(profile.manage_friends_cache_key(:npage => i.to_s))
    end

    blocks = profile.blocks.select{|b| b.kind_of?(FriendsBlock)}
    blocks.map(&:cache_keys).each{|ck|expire_timeout_fragment(ck)}
  end

end
