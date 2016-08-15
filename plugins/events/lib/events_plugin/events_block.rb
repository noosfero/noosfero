class EventsPlugin::EventsBlock < Block
  def view_title
    self.default_title
  end

  def events
    owner.events
  end

  def extra_option
    { }
  end

  def self.description
    _('Shows events in a calendar.')
  end

  def help
    _('This block shows events in a calendar.')
  end

  def default_title
    _('Events Calendar')
  end

  def api_content
    content = []
    events.each do |event|
      content << { title: event.title, id: event.id, date: event.start_date }
    end
    { events: content }
  end

  def display_api_content_by_default?
    false
  end

  def timeout
    4.hours
  end

  def self.expire_on
    { profile: [:article] }
  end
end
