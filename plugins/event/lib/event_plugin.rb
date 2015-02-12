class EventPlugin < Noosfero::Plugin

  def self.plugin_name
    _("Event Extras")
  end

  def self.plugin_description
    _("Include a new block to show the environment's or profiles' events information")
  end

  def self.extra_blocks
    { EventPlugin::EventBlock => { :type => [Community, Person, Enterprise, Environment] } }
  end

  def stylesheet?
    true
  end

  def js_files
    'event.js'
  end

end
