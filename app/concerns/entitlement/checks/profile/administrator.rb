module Entitlement::Checks::Profile
  class Administrator < Entitlement::Check
    alias :profile :object

    def self.level
      Entitlement::Levels.levels[:self]
    end

    def self.filter_condition(user)
<<-eos
      when member_id = #{user.id} and key = 'profile_admin' then #{level}
eos
    end

    def entitles?(user)
      user && (user.is_admin?(profile.environment) || user.is_admin?(profile))
    end
  end
end
