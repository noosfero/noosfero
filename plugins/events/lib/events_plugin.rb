class EventsPlugin < Noosfero::Plugin
  def self.plugin_name
    'EventsPlugin'
  end

  def self.plugin_description
    _('Adds a block that shows events in a calendar')
  end

  def self.extra_blocks
    {
      EventsPlugin::EventsBlock => { type: [Person, Community, Enterprise] }
    }
  end

  def self.has_admin_url?
    false
  end

  def stylesheet?
    true
  end
end
