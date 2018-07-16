module Entitlement::Checks
  class User < Entitlement::Check
    def self.level
      Entitlement::Levels.levels[:users]
    end

    def entitles?(user)
      user.present?
    end
  end
end
