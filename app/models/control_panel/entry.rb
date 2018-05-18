class ControlPanel::Entry
  class << self

    def identifier
      to_s.split('::').last.to_slug
    end

    def keywords
      ([identifier, name.to_slug, section] + custom_keywords.map(&:to_slug)).uniq
    end

    # Template Methods

    # Name displayed on the button.
    def name
    end

    # Section in which the button is displayed.
    def section
    end

    # Icon identifier to be used.
    def icon
      'exclamation'
    end

    # Integer define in which position the button will be displayed.
    def priority
      100
    end

    # Words that should be used to filter this option on the control panel filter
    def custom_keywords
      []
    end

    # Url button points to.
    def url(profile)
      {}
    end

    # Decides wether the button should be displayed based on the profile and
    # the request context.
    def display?(user, profile, context={})
      true
    end

    # HTML options passed to the link construction.
    def options
      {}
    end
  end
end
