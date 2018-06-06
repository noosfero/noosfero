class Entitlement::Check
  def initialize(object=nil)
    @object = object
  end

  attr_reader :object

  # Template Methods

  # Level of right this check entitles the user. Usually should be used
  # with Entitlement::Levels.levels[:some_level].
  def level
  end

  # Test conditions the user must match in order to be entitled this permission.
  def entitles?(user)
  end
end
