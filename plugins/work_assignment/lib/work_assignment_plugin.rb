class WorkAssignmentPlugin < Noosfero::Plugin

  def self.plugin_name
    "Work Assignment"
  end

  def self.plugin_description
    _("New kind of content for work organization.")
  end

  def content_types
    [WorkAssignmentPlugin::WorkAssignment] if context.profile.organization?
  end

  def stylesheet?
    true
  end

end
