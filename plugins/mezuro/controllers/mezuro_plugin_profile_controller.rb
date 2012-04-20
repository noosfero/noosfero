class MezuroPluginProfileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def project_state
    content = profile.articles.find(params[:id])
    project = content.project
    state = project.error.nil? ? project.state : "ERROR"
    render :text => state
  end

  def project_error
    content = profile.articles.find(params[:id])
    project = content.project
    render :partial => 'content_viewer/project_error', :locals => { :project => project }
  end

  def project_result
    
    content = profile.articles.find(params[:id])
    date = params[:date]
    project_result = date.nil? ? content.project_result : content.get_date_result(date)
    project = content.project
    render :partial => 'content_viewer/project_result', :locals => { :project_result => project_result}
  end 	

  def module_result
    content = profile.articles.find(params[:id])
    date = params[:date]
    project_result = date.nil? ? content.project_result : content.get_date_result(date)
    module_result = content.module_result(params[:module_name])
    render :partial => 'content_viewer/module_result', :locals => { :module_result =>  module_result}
  end

  def project_tree
    content = profile.articles.find(params[:id])
    date = params[:date]
    project_result = date.nil? ? content.project_result : content.get_date_result(date)
    project_result = content.project_result
    source_tree = project_result.node_of(params[:module_name])
    render :partial =>'content_viewer/source_tree', :locals => { :source_tree => source_tree, :project_name => content.project.name}
  end
  def choose_base_tool
    @configuration_name = params[:configuration_name]
    @tool_names = Kalibro::Client::BaseToolClient.new
  end

  def choose_metric
    @configuration_name = params[:configuration_name]
    @collector_name = params[:collector_name]
    @collector = Kalibro::Client::BaseToolClient.new.base_tool(@collector_name)
  end
  def new_metric_configuration
    metric_name = params[:metric_name]
    collector_name = params[:collector_name]
    collector = Kalibro::Client::BaseToolClient.new.base_tool(collector_name)
    @metric = collector.supported_metrics.find {|metric| metric.name == metric_name}
    @configuration_name = params[:configuration_name]
  end
  def edit_metric_configuration
    metric_name = params[:metric_name]
    @configuration_name = params[:configuration_name]
    @metric_configuration = Kalibro::Client::MetricConfigurationClient.new.metric_configuration(@configuration_name, metric_name)
    @metric = @metric_configuration.metric
  end
  def create_metric_configuration
    @configuration_name = params[:configuration_name]
    metric_configuration = new_metric_configuration_instance
    Kalibro::Client::MetricConfigurationClient.new.save(metric_configuration, @configuration_name)
    redirect_to "/#{profile.identifier}/#{@configuration_name.downcase.gsub(/\s/, '-')}"
  end

  def update_metric_configuration
    @configuration_name = params[:configuration_name]
    metric_name = params[:metric][:name]
    metric_configuration = Kalibro::Client::MetricConfigurationClient.new.metric_configuration(@configuration_name, metric_name)  
    assign_metric_configuration_instance (metric_configuration)
    Kalibro::Client::MetricConfigurationClient.new.save(metric_configuration, @configuration_name)
    redirect_to "/#{profile.identifier}/#{@configuration_name.downcase.gsub(/\s/, '-')}"
  end
  
  def new_range
    @metric_name = params[:metric_name]
    @configuration_name = params[:configuration_name]
  end
  
  def edit_range
    @metric_name = params[:metric_name]
    @configuration_name = params[:configuration_name]
    @beginning_id = params[:beginning_id]
    
    metric_configuration_client = Kalibro::Client::MetricConfigurationClient.new
    metric_configuration = metric_configuration_client.metric_configuration(@configuration_name, @metric_name)
    @range = metric_configuration.ranges.find{ |range| range.beginning == @beginning_id.to_f }
  end

  def create_range
    @range = new_range_instance
    configuration_name = params[:configuration_name]
    metric_name = params[:metric_name]
    beginning_id = params[:beginning_id]
    metric_configuration_client = Kalibro::Client::MetricConfigurationClient.new
    metric_configuration = metric_configuration_client.metric_configuration(configuration_name, metric_name)   
    metric_configuration.add_range(@range)
    metric_configuration_client.save(metric_configuration, configuration_name)
  end
  
  def update_range
    metric_name = params[:metric_name]
    configuration_name = params[:configuration_name]
    beginning_id = params[:beginning_id]
    metric_configuration_client = Kalibro::Client::MetricConfigurationClient.new
    metric_configuration = metric_configuration_client.metric_configuration(configuration_name, metric_name)
    index = metric_configuration.ranges.index{ |range| range.beginning == beginning_id.to_f }
    metric_configuration.ranges[index] = new_range_instance
    Kalibro::Client::MetricConfigurationClient.new.save(metric_configuration, configuration_name)
  end
  
  def remove_range
    configuration_name = params[:configuration_name]
    metric_name = params[:metric_name]
    beginning_id = params[:range_beginning]
    metric_configuration_client = Kalibro::Client::MetricConfigurationClient.new
    metric_configuration = metric_configuration_client.metric_configuration(configuration_name, metric_name)
    metric_configuration.ranges.delete_if { |range| range.beginning == beginning_id.to_f }.inspect
    Kalibro::Client::MetricConfigurationClient.new.save(metric_configuration, configuration_name)
    formatted_configuration_name = configuration_name.gsub(/\s/, '+')
    formatted_metric_name = metric_name.gsub(/\s/, '+')
    redirect_to "/profile/#{profile.identifier}/plugins/mezuro/edit_metric_configuration?configuration_name=#{formatted_configuration_name}&metric_name=#{formatted_metric_name}"
  end

  def remove_metric_configuration
    configuration_name = params[:configuration_name]
    metric_name = params[:metric_name]
    Kalibro::Client::MetricConfigurationClient.new.remove(configuration_name, metric_name)
    redirect_to "/#{profile.identifier}/#{configuration_name.downcase.gsub(/\s/, '-')}"
  end

  def module_metrics_history
    metric_name = params[:metric_name]
    content = profile.articles.find(params[:id])
    module_history = content.result_history(params[:module_name])
	date_history = module_history.collect { |x| x.date }
    metric_history = module_history.collect { |x| (x.metric_results.select { |y| y.metric.name.delete("() ") == metric_name })[0] }
    render :partial => 'content_viewer/metric_history', :locals => {:metric_history => metric_history, :date_history => date_history }
  end
  private 

  def new_metric_configuration_instance
    metric_configuration = Kalibro::Entities::MetricConfiguration.new
    metric_configuration.metric = Kalibro::Entities::NativeMetric.new
    assign_metric_configuration_instance (metric_configuration)
  end

  def assign_metric_configuration_instance (metric_configuration)   
    metric_configuration.metric.name = params[:metric][:name]
    metric_configuration.metric.description = params[:description]
    metric_configuration.metric.origin = params[:metric][:origin]
    metric_configuration.metric.scope = params[:scope]
    metric_configuration.metric.language = params[:language]
    metric_configuration.code = params[:metric_configuration][:code]
    metric_configuration.weight = params[:metric_configuration][:weight]
    metric_configuration.aggregation_form = params[:metric_configuration][:aggregation_form]
    metric_configuration
  end

  def new_range_instance
    range = Kalibro::Entities::Range.new
    range.beginning = params[:range][:beginning]
    range.end = params[:range][:end]
    range.label = params[:range][:label]
    range.grade = params[:range][:grade]
    range.color = params[:range][:color]
    range.comments = params[:range][:comments]
    range
  end

end
