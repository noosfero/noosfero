module SweeperHelper

  def expire_fragment(*args)
    ActionController::Base.new().expire_fragment(*args)
  end

  def expire_timeout_fragment(*args)
    ActionController::Base.new().expire_timeout_fragment(*args)
  end

  def expire_friends(profile)
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

    # friends blocks
    blocks = profile.blocks.select{|b| b.kind_of?(FriendsBlock)}
    blocks.map(&:cache_keys).each{|ck|expire_timeout_fragment(ck)}
  end

  def expire_communities(profile)
    # public communities page
    pages =  profile.communities.count / Noosfero::Constants::PROFILE_PER_PAGE + 1
    (1..pages).each do |i|
      expire_timeout_fragment(profile.communities_cache_key(:npage => i.to_s))
    end

    # communities block
    blocks = profile.blocks.select{|b| b.kind_of?(CommunitiesBlock)}
    blocks.map(&:cache_keys).each{|ck|expire_timeout_fragment(ck)}
  end

  def expire_enterprises(profile)
    # enterprises and favorite enterprises blocks
    blocks = profile.blocks.select {|b| [EnterprisesBlock, FavoriteEnterprisesBlock].any?{|klass| b.kind_of?(klass)} }
    blocks.map(&:cache_keys).each{|ck|expire_timeout_fragment(ck)}
  end

  def expire_profile_index(profile)
    expire_timeout_fragment(profile.relationships_cache_key)
  end
end
