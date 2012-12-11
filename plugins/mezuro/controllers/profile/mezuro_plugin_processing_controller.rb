#TODO refatorar todo o controller e seus testes funcionais
class MezuroPluginProcessingController < MezuroPluginProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def render_last_state
    last_state = Kalibro::Processing.last_processing_state_of(params[:repository_id].to_i)
    render :text => last_state
  end

  def processing
    date = params[:date]
    repository_id = params[:repository_id].to_i
    processing_class = Kalibro::Processing
    @processing = date.nil? ? processing_class.processing_of(repository_id) : processing_class.processing_with_date_of(repository_id, date)
    if @processing.state == 'ERROR'
      render :partial => 'processing_error'
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
