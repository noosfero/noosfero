# This is not a proper observer since is explicitly called in the profile model
class ProfileSweeper # < ActiveRecord::Observer
#  observe :profile
  include SweeperHelper

  def after_update(profile)
    expire_caches(profile)
  end

protected

  def expire_caches(profile)
    profile.members.each do |member|
      expire_communities(member) if profile.community?
      expire_enterprises(member) if profile.enterprise?
    end

    profile.blocks.each do |block|
      expire_timeout_fragment(block.cache_keys)
    end
  end
end
