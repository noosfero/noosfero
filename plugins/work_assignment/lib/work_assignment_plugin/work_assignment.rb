class WorkAssignmentPlugin::WorkAssignment < Folder

  def self.icon_name(article = nil)
    'work-assignment'
  end

  def self.short_description
    _('Work Assignment')
  end

  def self.description
    _('Defines a work to be done by the members and receives their submissions about this work.')
  end

  def accept_comments?
    true
  end

  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/work_assignment.html.erb'
    end
  end

end
