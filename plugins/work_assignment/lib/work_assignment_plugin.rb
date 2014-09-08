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
    [WorkAssignmentPlugin::WorkAssignment] if context.respond_to?(:profile) && context.profile.organization?
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
    block = proc do
      path = params[:page]
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


  def article_extra_contents(article_id)
    proc do
        @article = Article.find_by_id(article_id)
        if params[:parent_id] && !@article.nil? && @article.type == "WorkAssignmentPlugin::WorkAssignment"
          render :partial => 'notify_checkbox',  :locals => { :size => '45'} 
        end      
    end
  end

  def check_extra_parameters (uploaded_files, params = {})   
    @email_notification = params[:article_email_notification]
   # uploaded_files = params[:uploaded_files]
    id = params[:parent_id]
    if @email_notification == 'true'
      proc do
        @back_to = url_for :controller => 'work_assignment_plugin_cms', :action => 'send_email', :id => id, :files_id => uploaded_files, :confirm => true
      end
    end
  end

end