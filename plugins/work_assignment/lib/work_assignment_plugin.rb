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

  def content_remove_new(content)
    content.kind_of?(WorkAssignmentPlugin::WorkAssignment)
  end

  def content_remove_upload(content)
    !content.profile.members.include?(context.send(:user))
  end

end
