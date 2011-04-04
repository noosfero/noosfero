# This is not a proper observer since is explicitly called in the profile model
class ProfileSweeper # < ActiveRecord::Observer
#  observe :profile
  include SweeperHelper

  def after_update(profile)
    expire_caches(profile)
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
  end

  def expire_statistics_block_cache(profile)
    blocks = profile.environment.blocks.select { |b| b.kind_of?(EnvironmentStatisticsBlock) }
    blocks.map(&:cache_key).each{|ck|expire_timeout_fragment(ck)}
  end
end
