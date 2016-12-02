class AccessLevels
  OPTIONS = ['visitors', 'users', 'related', 'self']

  LABELS = {'visitors' => _('Visitors'), 'users' => _('Logged users')}
  PERSON_LABELS = LABELS.merge({'self' => _('Me'), 'related' => _('Friends')})
  GROUP_LABELS = LABELS.merge({'self' => _('Administrators'), 'related' => _('Members')})

  VALUES = {'self' => 3, 'related' => 2, 'users' => 1, 'visitors' => 0}

  def self.options(base_level=0)
    OPTIONS[base_level..-1]
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
    when 'related'
      profile.person? ? profile.friends.include?(user) : profile.members.include?(user)
    when 'users'
      user.present?
    when 'visitors'
      true
    end
  end
end
