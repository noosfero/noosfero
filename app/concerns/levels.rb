class Levels

  LABELS = { visitors: _('Visitors'), users: _('Logged users'), related: _('Friends / Members'), self: _('Me / Administrators'), nobody: _('Nobody')}
  PERSON_LABELS = LABELS.merge({related: _('Friends'), self: _('Me')})
  GROUP_LABELS = LABELS.merge({related: _('Members'), self: _('Administrators')})

  def self.levels
    # Overwrite on subclasses
  end

  def self.range_options(base_level=0, top_level=-1)
    levels.keys[base_level..top_level]
  end

  # TODO This options needs some tweak on the slider.js code to work properly.
  def self.pick_options(values)
    values.sort.uniq.map {|value| levels.keys[value]}
  end

  def self.labels(profile)
    if profile.try(:person?)
      PERSON_LABELS
    elsif profile.try(:organization?)
      GROUP_LABELS
    else
      LABELS
    end
  end

  def self.permission(user, profile)
    value = 0
    if user.present?
      value = 1

      if profile.present?
        if profile.person? ? profile.friends.include?(user) : profile.members.include?(user)
        value = 2
        end
        if user == profile || profile.admins.include?(user) || profile.environment.admins.include?(user)
          value = 3
        end
      end
    end
    return value
  end
end
