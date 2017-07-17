class AccessLevels < Levels

  def self.levels
    {
      # Everyone
      visitors: 0,

      # Any logged user
      users: 1,

      # Only friends and members
      related: 2,

      # Only owners or administrators
      self: 3,

      # Nobody
      nobody: 4,
    }
  end

  def self.can_access?(requirement, user, profile)
    permission(user, profile) >= requirement.to_i
  end
end
