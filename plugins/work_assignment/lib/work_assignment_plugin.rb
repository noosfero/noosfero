class WorkAssignmentPlugin < Noosfero::Plugin

  def self.plugin_name
    "Work Assignment"
  end

  def self.plugin_description
    _("New kind of content for organizations.")
  end

  def self.can_download_submission?(user, submission)
    work_assignment = submission.parent.parent
    work_assignment.publish_submissions || (user && (submission.author == user || user.has_permission?('view_private_content', work_assignment.profile)))
  end

  def self.is_submission?(content)
    content && content.parent && content.parent.parent && content.parent.parent.kind_of?(WorkAssignmentPlugin::WorkAssignment)
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
    if content.kind_of?(WorkAssignmentPlugin::WorkAssignment)
      !content.profile.members.include?(context.send(:user))
    end
  end

  def content_viewer_controller_filters
    block = lambda do
      path = params[:page].join('/')
      content = profile.articles.find_by_path(path)

      if WorkAssignmentPlugin.is_submission?(content) && !WorkAssignmentPlugin.can_download_submission?(user, content)
        render_access_denied
      end
    end

    { :type => 'before_filter',
      :method_name => 'work_assingment_only_admin_or_owner_download',
      :options => {:only => 'view_page'},
      :block => block }
  end

end
