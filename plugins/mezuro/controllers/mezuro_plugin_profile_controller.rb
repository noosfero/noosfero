class MezuroPluginProfileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')
  
  def project_state
    @content = profile.articles.find(params[:id])
    project = @content.project
    state = project.error.nil? ? project.state : "ERROR"
    render :text => state
  end

  def project_error
    @content = profile.articles.find(params[:id])
    @project = @content.project
    render :partial => 'content_viewer/project_error'
  end

  def project_result
    @content = profile.articles.find(params[:id])
    date = params[:date]
    @project_result = date.nil? ? @content.project_result : @content.project_result_with_date(date)
    render :partial => 'content_viewer/project_result'
  end 	

  def module_result
    @content = profile.articles.find(params[:id])
    @module_result = @content.module_result(params)
    render :partial => 'content_viewer/module_result'
  end

  def project_tree
    @content = profile.articles.find(params[:id])
    date = params[:date]
    project_result = date.nil? ? @content.project_result : @content.project_result_with_date(date)
    @project_name = @content.project.name
    @source_tree = project_result.node_of(params[:module_name])
    render :partial =>'content_viewer/source_tree'
  end

  def module_metrics_history
    metric_name = params[:metric_name]
    @content = profile.articles.find(params[:id])
    module_history = @content.result_history(params[:module_name])
    @score_history = filtering_metric_history(metric_name, module_history)
    render :partial => 'content_viewer/score_history'
  end

  def module_grade_history
    @content = profile.articles.find(params[:id])
    modules_results = @content.result_history(params[:module_name])
    @score_history = modules_results.collect { |module_result| module_result.grade }
    render :partial => 'content_viewer/score_history'
  end
  
  private
  
  def filtering_metric_history(metric_name, module_history)
    metrics_history = module_history.map do |module_result|
      module_result.metric_results
    end
    metric_history =  metrics_history.map do |array_of_metric_result|
      (array_of_metric_result.select do |metric_result|
        metric_result.metric.name.delete("() ") == metric_name
      end).first
    end
    metric_history.map do |metric_result|
      metric_result.value
    end
  end
end
