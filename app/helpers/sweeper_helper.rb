module SweeperHelper

  def expire_fragment(*args)
    ActionController::Base.new().expire_fragment(*args)
  end

  alias :expire_timeout_fragment :expire_fragment

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
    BlockSweeper.expire_blocks(blocks)
  end

  def expire_communities(profile)
    # public communities page
    pages =  profile.communities.count / Noosfero::Constants::PROFILE_PER_PAGE + 1
    (1..pages).each do |i|
      expire_timeout_fragment(profile.communities_cache_key(:npage => i.to_s))
    end

    # communities block
    blocks = profile.blocks.select{|b| b.kind_of?(CommunitiesBlock)}
    BlockSweeper.expire_blocks(blocks)
  end

  def expire_enterprises(profile)
    # enterprises and favorite enterprises blocks
    blocks = profile.blocks.select {|b| [EnterprisesBlock, FavoriteEnterprisesBlock].any?{|klass| b.kind_of?(klass)} }
    BlockSweeper.expire_blocks(blocks)
  end

  def expire_profile_index(profile)
    expire_timeout_fragment(profile.relationships_cache_key)
  end
end
