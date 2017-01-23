class AccessLevels

  LEVELS = {
    # The profile will always be visible, even to anonymous users
    visitors: 0,

    # Any logged user will be able to view the profile
    users: 1,

    # The profile will be visible for friends and members
    related: 2,

    # Only owners or admins can view the profile
    self: 3
  }

  LABELS = { visitors: _('Visitors'), users: _('Logged users')}
  PERSON_LABELS = LABELS.merge({self: _('Me'), related: _('Friends')})
  GROUP_LABELS = LABELS.merge({self: _('Administrators'), related: _('Members')})

  def self.options(base_level=0)
    LEVELS.keys[base_level..-1]
  end

  def self.labels(profile)
    if profile.person?
      PERSON_LABELS
    elsif profile.organization?
      GROUP_LABELS
    else
      LABELS
    end
  end

  def self.can_access?(permission, user, profile)
    return true if user == profile || profile.admins.include?(user) || profile.environment.admins.include?(user)
    case permission
    when LEVELS[:related]
      profile.person? ? profile.friends.include?(user) : profile.members.include?(user)
    when LEVELS[:users]
      user.present?
    when LEVELS[:visitors]
      true
    end
  end
end
