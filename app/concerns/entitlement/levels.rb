module Entitlement
  class Levels
    LABELS = { visitors: _('Visitors'), users: _('Logged users'),
               related: _('Friends / Members'),
               self: _('Me / Administrators'),
               nobody: _('Nobody')}
    PERSON_LABELS = LABELS.merge({related: _('Friends'),
                                  self: _('Me'),
                                  follower: _('Followers')})
    GROUP_LABELS = LABELS.merge({related: _('Members'),
                                 self: _('Administrators')})

    class << self

      def min_level
        0
      end

      def max_level
        30
      end

      def levels
        {
          # Everyone
          visitors: min_level,

          # Any logged user
          users: 10,

          # Only friends and members
          related: 20,

          # Admins or owner
          self: max_level,

          # Nobody
          nobody: max_level + 10
        }
      end

      def index(level)
        levels.values.find_index(level)
      end

      def range_options(base=0, top=-2)
        levels.keys[base..top]
      end

      def labels(profile)
        if profile.try(:person?)
          PERSON_LABELS
        elsif profile.try(:organization?)
          GROUP_LABELS
        else
          LABELS
        end
      end

      def label(level, profile)
        labels(profile)[levels.invert[level]]
      end
    end
  end
end
