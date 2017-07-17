class RestrictionLevels < Levels

  def self.levels
    {
    # Nobody
      nobody: 0,

      # Only visitors
      visitors: 1,

      # Any logged user
      users: 2,

      # Friends and members
      related: 3,

      # Owners or administrators
      self: 4,
    }
  end

  def self.is_restricted?(requirement, user, profile)
    permission(user, profile) < requirement.to_i
  end
end
