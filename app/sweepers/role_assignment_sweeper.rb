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
      expire_cache(role_assignment.accessor) if role_assignment.accessor.kind_of?(Profile)
      expire_cache(role_assignment.resource) if role_assignment.resource.kind_of?(Profile)
    end

    def expire_cache(profile)
      per_page = Noosfero::Constants::PROFILE_PER_PAGE

      profile.cache_keys(per_page: per_page).each { |ck| expire_timeout_fragment(ck) }
      expire_timeout_fragment(profile.members_cache_key(per_page: per_page))

      profile.blocks_to_expire_cache.each { |block|
        blocks = profile.blocks.select { |b| b.kind_of?(block) }
        BlockSweeper.expire_blocks(blocks)
      }

      expire_blocks_cache(profile, [:role_assignment])
    end
end
