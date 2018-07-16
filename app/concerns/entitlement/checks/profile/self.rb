module Entitlement::Checks::Profile
  class Self < Entitlement::Check
    alias :profile :object

    def self.level
      Entitlement::Levels.levels[:self] + 1 # Prioritize this check
    end

    def entitles?(user)
      user == profile
    end
  end
end
