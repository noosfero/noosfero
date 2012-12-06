#TODO refatorar todo o controller e seus testes funcionais
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

  private
  
  def module_result(repository_id, date = nil)
    @processing ||= date.nil? ? processing(repository_id) : processing_with_date(repository_id, date)
    begin
      @module_result ||= Kalibro::ModuleResult.find(@processing.results_root_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @module_result
  end

  def result_history(module_result_id)
    begin
      @result_history ||= Kalibro::MetricResult.history_of(module_result_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
  end

end
