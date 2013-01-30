class MezuroPluginMetricConfigurationController < MezuroPluginMyprofileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def choose_metric
    @configuration_content = profile.articles.find(params[:id])
    @base_tools = Kalibro::BaseTool.all
  end

  def new_native
    @configuration_content = profile.articles.find(params[:id])
    @reading_group_names_and_ids = reading_group_names_and_ids
    @metric = Kalibro::BaseTool.find_by_name(params[:base_tool_name]).metric params[:metric_name]
    @metric_configuration = Kalibro::MetricConfiguration.new :base_tool_name => params[:base_tool_name], :metric => @metric
  end

  def edit_native
    params_to_edit_view
  end

  def new_compound
    @configuration_content = profile.articles.find(params[:id])
    @metric_configurations = @configuration_content.metric_configurations
    @reading_group_names_and_ids = reading_group_names_and_ids
    metric = Kalibro::Metric.new :compound => true
    @metric_configuration = Kalibro::MetricConfiguration.new :metric => metric
    if configuration_content_has_errors?
      redirect_to_error_page @configuration_content.errors[:base]
    end
  end

  def edit_compound    
    params_to_edit_view
  end

  def create
    configuration_content = profile.articles.find(params[:id])
    metric_configuration = Kalibro::MetricConfiguration.create(params[:metric_configuration])
    
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    else
      redirect_to(metric_configuration_url(configuration_content, metric_configuration.id))
    end
  end

  def update
    @configuration_content = profile.articles.find(params[:id])
    metric_configurations = @configuration_content.metric_configurations
    metric_configuration = find_metric_configuration(metric_configurations, params[:metric_configuration][:id].to_i)
    metric_configuration.update_attributes params[:metric_configuration]
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    else
      redirect_to @configuration_content.view_url
    end
  end

  def remove
    configuration_content = profile.articles.find(params[:id])
    configuration_id = configuration_content.configuration_id
    metric_configuration = Kalibro::MetricConfiguration.new({:id => params[:metric_configuration_id].to_i})
    metric_configuration.destroy
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    else
      redirect_to configuration_content.view_url
    end
  end

  private

  def find_metric_configuration (metric_configurations, metric_configuration_id)
    metric_configurations.select {|metric_configuration| metric_configuration.id == metric_configuration_id }.first
  end

  def reading_group_names_and_ids
    array = Kalibro::ReadingGroup.all.map { |reading_group| [reading_group.name, reading_group.id] }
    array.sort { |x,y| x.first.downcase <=> y.first.downcase }
  end

  def metric_configuration_has_errors? metric_configuration
    not metric_configuration.errors.empty?
  end

  def configuration_content_has_errors?
    not @configuration_content.errors[:base].nil?
  end

  def metric_configuration_url(configuration_content, metric_configuration_id)
    url = configuration_content.view_url
    url[:controller] = controller_name
    url[:id] = configuration_content.id
    url[:metric_configuration_id] = metric_configuration_id
    url[:action] = (params[:metric_configuration][:metric][:compound] == "true" ? "edit_compound" : "edit_native")
    url
  end

  def params_to_edit_view
    @configuration_content = profile.articles.find(params[:id])
    @metric_configurations = @configuration_content.metric_configurations
    @metric_configuration = find_metric_configuration(@metric_configurations, params[:metric_configuration_id].to_i)
    @metric = @metric_configuration.metric
    @reading_group_names_and_ids = reading_group_names_and_ids
    @ranges = Kalibro::Range.ranges_of(@metric_configuration.id)
  end

end

