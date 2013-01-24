class MezuroPluginMetricConfigurationController < MezuroPluginMyprofileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def choose_metric
    @configuration_content = profile.articles.find(params[:id])
    @base_tools = Kalibro::BaseTool.all
  end

  def new_native
    @configuration_content = profile.articles.find(params[:id])
    @base_tool_name = params[:base_tool_name]
    @metric = Kalibro::BaseTool.find_by_name(@base_tool_name).metric params[:metric_name]
    @reading_group_names_and_ids = reading_group_names_and_ids
  end

  def create_native
    metric_configuration = Kalibro::MetricConfiguration.new(params[:metric_configuration])
    metric_configuration.save

    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    else
      id = params[:id]
      redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/metric_configuration/edit_native?id=#{id}&metric_configuration_id=#{metric_configuration.id}"
    end
  end

  def edit_native
    @configuration_content = profile.articles.find(params[:id])
    configuration_id = @configuration_content.configuration_id
    metric_configurations = Kalibro::MetricConfiguration.metric_configurations_of(configuration_id)
    @metric_configuration = find_metric_configuration(metric_configurations, params[:metric_configuration_id].to_i)
    @metric = @metric_configuration.metric
    @reading_group_names_and_ids = reading_group_names_and_ids
    @ranges = Kalibro::Range.ranges_of(@metric_configuration.id)
  end
=begin
  def new_compound_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric_configurations = @configuration_content.metric_configurations
    if configuration_content_has_errors?
      redirect_to_error_page @configuration_content.errors[:base]
    end
  end


  def edit_compound_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, params[:metric_name])
    @metric_configurations = @configuration_content.metric_configurations
    @metric = @metric_configuration.metric
  end


  def create_compound_metric_configuration
    id = params[:id]
    metric_name = params[:metric_configuration][:metric][:name]
    metric_configuration = Kalibro::MetricConfiguration.new(params[:metric_configuration])
    metric_configuration.save
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    else
      redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/metric_configuration/edit_compound_metric_configuration?id=#{id}&metric_name=#{metric_name.gsub(/\s/, '+')}"
    end
  end

  def update_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_configuration][:metric][:name]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, metric_name)
    metric_configuration.update_attributes params[:metric_configuration]
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    else
      redirect_to "/#{profile.identifier}/#{@configuration_content.slug}"
    end
  end

  def update_compound_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_configuration][:metric][:name]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, metric_name)
    metric_configuration.update_attributes params[:metric_configuration]
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    else
      redirect_to "/#{profile.identifier}/#{@configuration_content.slug}"
    end
  end

  def remove_metric_configuration
    configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_name]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(configuration_content.name, metric_name)
    metric_configuration.destroy
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    else
      redirect_to "/#{profile.identifier}/#{configuration_content.slug}"
    end
  end
=end 
  
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
end
