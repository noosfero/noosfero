module Entitlement::Checks
  class Visitor < Entitlement::Check
    def self.level
      Entitlement::Levels.levels[:visitors]
    end

    def entitles?(user)
      true
    end
  end
end
