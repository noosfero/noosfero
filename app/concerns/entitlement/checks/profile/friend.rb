module Entitlement::Checks::Profile
  class Friend < Entitlement::Check
    alias :profile :object

    def self.level
      Entitlement::Levels.levels[:related]
    end

    def self.filter_condition(user)
<<-eos
      when friend_id = #{user.id} then #{level}
      when person_id = #{user.id} then #{level}
eos
    end

    def entitles?(user)
      user && profile.person? && (user.is_a_friend?(profile) || profile.is_a_friend?(user))
    end
  end
end
