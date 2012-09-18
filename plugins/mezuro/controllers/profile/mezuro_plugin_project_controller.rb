class MezuroPluginProjectController < MezuroPluginProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def project_state
    @content = profile.articles.find(params[:id])
    project = @content.project
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      state = project.kalibro_error.nil? ? project.state : "ERROR"
      render :text => state
    end
  end

  def project_error
    @content = profile.articles.find(params[:id])
    @project = @content.project
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      render :partial => 'project_error'
    end
  end

  def project_result
    @content = profile.articles.find(params[:id])
    date = params[:date]
    @project_result = date.nil? ? @content.project_result : @content.project_result_with_date(date)
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      render :partial => 'project_result'
    end
  end

  def project_tree
    @content = profile.articles.find(params[:id])
    date = params[:date]
    project_result = date.nil? ? @content.project_result : @content.project_result_with_date(date)
    @project_name = @content.project.name if not @content.project.nil?
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      @source_tree = project_result.node(params[:module_name])
      render :partial =>'source_tree'
    end
  end

end
