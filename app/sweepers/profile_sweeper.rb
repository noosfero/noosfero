# This is not a proper observer since is explicitly called in the profile model
class ProfileSweeper # < ActiveRecord::Observer
#  observe :profile
  include SweeperHelper

  def after_update(profile)
    self.delay.expire_caches profile
  end

  def after_create(profile)
    expire_statistics_block_cache(profile)
  end

protected

  def expire_caches(profile)
    profile.members.each do |member|
      expire_communities(member) if profile.community?
      expire_enterprises(member) if profile.enterprise?
      expire_profile_index(member) if profile.enterprise?
    end

    expire_profile_index(profile) if profile.person?

    profile.blocks.each do |block|
      expire_timeout_fragment(block.cache_key)
    end

    expire_blogs(profile) if profile.organization?
  end

  def expire_statistics_block_cache(profile)
    blocks = profile.environment.blocks.select { |b| b.kind_of?(EnvironmentStatisticsBlock) }
    BlockSweeper.expire_blocks(blocks)
  end

  def expire_blogs(profile)
    profile.blogs.select{|b| !b.empty?}.each do |blog|
      pages = blog.posts.count / blog.posts_per_page + 1
      ([nil] + (1..pages).to_a).each do |i|
        expire_timeout_fragment(blog.cache_key({:npage => i}))
        expire_timeout_fragment(blog.cache_key({:npage => i}, profile))
      end
    end
  end

end
