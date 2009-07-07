class RoleAssignmentSweeper < ActiveRecord::Observer
  observe :role_assignment
  include SweeperHelper

  def after_create(role_assignment)
    expire_caches(role_assignment)
  end

  def after_destroy(role_assignment)
    expire_caches(role_assignment)
  end

protected

  def expire_caches(role_assignment)
    expire_cache(role_assignment.accessor)
    expire_cache(role_assignment.resource) if role_assignment.resource.respond_to?(:cache_keys)
  end

  def expire_cache(profile)
    profile.cache_keys.each { |ck|
      cache_key = ck.gsub(/(.)-\d.*$/, '\1')
      expire_timeout_fragment(/#{cache_key}/)
    }

    profile.blocks_to_expire_cache.each { |block|
      blocks = profile.blocks.select{|b| b.kind_of?(block)}
      blocks.map(&:cache_keys).each{|ck|expire_timeout_fragment(ck)}
    }
  end

end
