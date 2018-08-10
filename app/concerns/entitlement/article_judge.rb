module Entitlement::ArticleJudge
  include Entitlement::Judge

  def self.included(base)
    base.extend(AccessibleQueries)
    base.include(Entitlement::AccessibleTo)
  end

  def checks
    @checks ||= profile.checks + [
      Entitlement::Checks::Article::Exception.new(self)
    ]
  end

  def access_requirement
    [access, profile_requirement].max
  end

  def profile_requirement
    profile.try(:access_requirement) || 0
  end

  def access_levels
    base = Entitlement::Levels.index(profile.access)
    return Entitlement::Levels.range_options(base)
  end
end
