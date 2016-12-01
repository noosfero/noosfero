class AccessLevels
  OPTIONS = ['visitors', 'users', 'related', 'self']

  LABELS = {'visitors' => _('Visitors'), 'users' => _('Logged users')}
  PERSON_LABELS = LABELS.merge({'self' => _('Me'), 'related' => _('Friends')})
  GROUP_LABELS = LABELS.merge({'self' => _('Administrators'), 'related' => _('Members')})

  VALUES = {'self' => 3, 'related' => 2, 'users' => 1, 'visitors' => 0}

  def self.options(profile, base_level=0)
    OPTIONS[base_level..-1]
  end

  def self.labels(profile)
    profile.person? ? PERSON_LABELS : GROUP_LABELS
  end
end
