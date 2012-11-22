class MezuroPluginProjectController < MezuroPluginProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def processing_state
    @content = profile.articles.find(params[:id])
    processing = @content.processing
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      render :text => processing.state
    end
  end

  def processing_error
    @content = profile.articles.find(params[:id])
    @processing = @content.processing
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      render :partial => 'processing_error'
    end
  end

  def processing
    @content = profile.articles.find(params[:id])
    date = params[:date]
    @processing = date.nil? ? @content.processing : @content.processing_with_date(date)
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      render :partial => 'processing'
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
