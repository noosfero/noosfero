module Entitlement::Checks::Profile
  class Member < Entitlement::Check
    alias :profile :object

    def self.level
      Entitlement::Levels.levels[:related]
    end

    def self.filter_condition(user)
<<-eos
      when member_id = #{user.id} then #{level}
eos
    end

    def entitles?(user)
      user && profile.organization? && user.is_member_of?(profile)
    end
  end
end
