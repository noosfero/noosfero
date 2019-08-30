class AgendaContext < GenericContext
  def content_types
    [
      Event
    ]
  end

  class Directory
    def initialize(args = {})
      @name = _("Agenda")
      @profile = args[:profile]
    end

    def name
      @name
    end

    def profile
      @profile
    end

    def hierarchy
      []
    end
  end

  def directory_to_publish
    Directory.new(profile: selected_profile)
  end
end
