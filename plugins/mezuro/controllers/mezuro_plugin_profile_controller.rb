class MezuroPluginProfileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def error_page
    @message = params[:message]
  end

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
      render :partial => 'content_viewer/project_error'
    end
  end

  def project_result
    @content = profile.articles.find(params[:id])
    date = params[:date]
    @project_result = date.nil? ? @content.project_result : @content.project_result_with_date(date)
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      render :partial => 'content_viewer/project_result'
    end
  end

  def module_result
    @content = profile.articles.find(params[:id])
    @module_result = @content.module_result(params)
    @module = @module_result.module
    @module_label = "#{@module.name} (#{@module.granularity})"
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      render :partial => 'content_viewer/module_result'
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
      render :partial =>'content_viewer/source_tree'
    end
  end

  def module_metrics_history
    metric_name = params[:metric_name]
    @content = profile.articles.find(params[:id])
    module_history = @content.result_history(params[:module_name])
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      @score_history = filtering_metric_history(metric_name, module_history)
      render :partial => 'content_viewer/score_history'
    end
  end

  def module_grade_history
    @content = profile.articles.find(params[:id])
    modules_results = @content.result_history(params[:module_name])
    if project_content_has_errors?
      redirect_to_error_page(@content.errors[:base])
    else
      @score_history = modules_results.map do |module_result|
        [module_result.grade, format_date_to_simple_form(module_result.date)]
      end
      render :partial => 'content_viewer/score_history'
    end
  end

  private

  def filtering_metric_history(metric_name, module_history)
    metrics_history = module_history.map do |module_result|
      [module_result.metric_results, format_date_to_simple_form(module_result.date)]
    end
    metric_history =  metrics_history.map do |metric_results_with_date|
      [(metric_results_with_date.first.select do |metric_result|
        metric_result.metric.name.delete("() ") == metric_name
      end).first, metric_results_with_date.last]
    end
    metric_history.map do |metric_result_with_date|
      [metric_result_with_date.first.value, metric_result_with_date.last]
    end
  end

  def redirect_to_error_page(message)
    message = URI.escape(CGI.escape(message),'.')
    redirect_to "/profile/#{profile.identifier}/plugins/mezuro/error_page?message=#{message}"
  end

  def project_content_has_errors?
    not @content.errors[:base].nil?
  end

  def format_date_to_simple_form date
    date.to_s[0..9]
  end

end
