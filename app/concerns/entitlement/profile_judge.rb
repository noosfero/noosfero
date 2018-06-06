module Entitlement::ProfileJudge
  include Entitlement::Judge

  def self.included(base)
    base.extend(AccessibleQueries)
    base.include(Entitlement::AccessibleTo)
  end

  def checks
    @checks ||= [
      Entitlement::Checks::Visitor.new,
      Entitlement::Checks::User.new,
      Entitlement::Checks::Profile::Friend.new(self),
      Entitlement::Checks::Profile::Member.new(self),
      Entitlement::Checks::Profile::Self.new(self),
      Entitlement::Checks::Profile::Administrator.new(self),
      Entitlement::Checks::Profile::ViewPrivateContent.new(self)
    ]
  end

  def access_requirement
    return Entitlement::Levels.levels[:self] if !visible
    if secret
      [Entitlement::Levels.levels[:related], access].max
    else
      access
    end
  end

  def menu_block_requirement
    self.person? ? Entitlement::Levels.levels[:users] : Entitlement::Levels.levels[:visitors]
  end

  def wall_requirement
    wall_access
  end

  def access_levels
    return Entitlement::Levels.range_options
  end

  def wall_access_levels
    base = Entitlement::Levels.index(access)
    return Entitlement::Levels.range_options(base)
  end
end
