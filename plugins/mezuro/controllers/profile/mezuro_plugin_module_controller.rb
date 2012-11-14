class MezuroPluginModuleController < MezuroPluginProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def module_result
    project_content = profile.articles.find(params[:id])
    repositories = project_content.repositories
    @module_result = project_content.module_result(repositories.first.id)
    @metric_results = Kalibro::MetricResult.metric_results_of(@module_result.id)
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      render :partial => 'module_result'
    end
  end
 
  def module_metrics_history
    module_result_id = params[:module_result_id]
    @content = profile.articles.find(params[:id])
    module_history = @content.result_history(params[:module_result_id])
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      @score_history = filtering_metric_history(metric_name, module_history)
      render :partial => 'score_history'
    end
  end

  def module_grade_history
    @content = profile.articles.find(params[:id])
    modules_results = @content.result_history(params[:module_result_id])
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      @score_history = modules_results.map do |module_result|
        [module_result.grade, format_date_to_simple_form(module_result.date)]
      end
      render :partial => 'score_history'
    end
  end

  private

  def filtering_metric_history(metric_name, module_history)
    metrics_history = module_history.select do |m|
      m.metric_result.configuration.metric.name.delete("() ") == metric_name
    end
    
    metric_history = metrics_history.map do |m|
      [m.metric_result.value, format_date_to_simple_form(m.date)]
    end
  end

  def format_date_to_simple_form date
    date.to_s[0..9]
  end

end
