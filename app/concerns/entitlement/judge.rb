# This module assumes that the class it is being included into defines the
# method #checks which returns an array of Entitlement::Levels::Check objects and
# access_requirement which returns an integer defining the level of access
# required.

module Entitlement::Judge
  def entitles?(user=nil, action = :access)
    entitlement(user) >= requirement(action)
  end

  alias display_to? entitles?

  def demands?(user, action = :access)
    entitlement(user) <= requirement(action)
  end

  def ordered_checks
    @ordered_checks ||= checks.sort_by {|check| check.class.level}.reverse
  end

  def entitlement(user)
    ordered_checks.each do |check|
      return check.class.level if check.entitles?(user)
    end
  end

  def requirement(action)
    self.send("#{action}_requirement")
  end
end
