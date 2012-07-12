class MezuroPluginMyprofileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

 
  def choose_base_tool
    @configuration_content = profile.articles.find(params[:id])
    @base_tools = Kalibro::BaseTool.all_names
  end

  def choose_metric
    @configuration_content = profile.articles.find(params[:id])
    @base_tool = params[:base_tool]
    @supported_metrics = Kalibro::BaseTool.find_by_name(@base_tool).supported_metrics
  end
  
  def new_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric = Kalibro::BaseTool.find_by_name(params[:base_tool]).metric params[:metric_name]
  end
  
  def new_compound_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric_configurations = @configuration_content.metric_configurations
  end
  
  def edit_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric_configuration = Kalibro::Client::MetricConfigurationClient.metric_configuration(@configuration_content.name, params[:metric_name])
    @metric = @metric_configuration.metric
  end

  def edit_compound_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric_configuration = Kalibro::Client::MetricConfigurationClient.metric_configuration(@configuration_content.name, params[:metric_name])
    @metric_configurations = @configuration_content.metric_configurations
    @metric = @metric_configuration.metric
  end
  
  def create_metric_configuration
    configuration_content = profile.articles.find(params[:id])
    metric_name = generic_metric_configuration_creation(new_metric_configuration_instance, configuration_content.name)
    redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_metric_configuration?id=#{configuration_content.id}&metric_name=#{metric_name.gsub(/\s/, '+')}"
  end
  
  def create_compound_metric_configuration
    configuration_content = profile.articles.find(params[:id])
    metric_name = generic_metric_configuration_creation(new_compound_metric_configuration_instance, configuration_content.name)
    redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_compound_metric_configuration?id=#{configuration_content.id}&metric_name=#{metric_name.gsub(/\s/, '+')}"
  end

  def update_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    auxiliar_update_metric_configuration(Kalibro::Entities::MetricConfiguration::NATIVE_TYPE)
    redirect_to "/#{profile.identifier}/#{@configuration_content.slug}"
  end

  def update_compound_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    auxiliar_update_metric_configuration(Kalibro::Entities::MetricConfiguration::COMPOUND_TYPE)
    redirect_to "/#{profile.identifier}/#{@configuration_content.slug}"
  end
  
  def new_range
    @configuration_content = profile.articles.find(params[:id])
    @metric_name = params[:metric_name]
  end
  
  def edit_range
    @configuration_content = profile.articles.find(params[:id])
    @metric_name = params[:metric_name]
    @beginning_id = params[:beginning_id]
    
    metric_configuration = Kalibro::Client::MetricConfigurationClient.metric_configuration(@configuration_content.name, @metric_name)
    @range = metric_configuration.ranges.find{ |range| range.beginning == @beginning_id.to_f }
  end

  def create_range
    @configuration_content = profile.articles.find(params[:id])
    @range = new_range_instance
    metric_name = params[:metric_name]
    beginning_id = params[:beginning_id]

    metric_configuration = Kalibro::Client::MetricConfigurationClient.metric_configuration(@configuration_content.name, metric_name)   
    metric_configuration.add_range(@range)
    Kalibro::Client::MetricConfigurationClient.new.save(metric_configuration, @configuration_content.name)
  end
  
  def update_range
    configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_name]
    beginning_id = params[:beginning_id]
    metric_configuration = Kalibro::Client::MetricConfigurationClient.metric_configuration(configuration_content.name, metric_name)
    index = metric_configuration.ranges.index{ |range| range.beginning == beginning_id.to_f }
    metric_configuration.ranges[index] = new_range_instance
    Kalibro::Client::MetricConfigurationClient.new.save(metric_configuration, configuration_content.name)
  end
  
  def remove_range
    configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_name]
    beginning_id = params[:range_beginning]
    
    metric_configuration = Kalibro::Client::MetricConfigurationClient.metric_configuration(configuration_content.name, metric_name)
    metric_configuration.ranges.delete_if { |range| range.beginning == beginning_id.to_f }.inspect
    Kalibro::Client::MetricConfigurationClient.new.save(metric_configuration, configuration_name)
    formatted_metric_name = metric_name.gsub(/\s/, '+')
    if metric_configuration.metric.class == Kalibro::Entities::CompoundMetric
      redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_compound_metric_configuration?id=#{configuration_content.id}&metric_name=#{formatted_metric_name}"
    else
      redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_metric_configuration?id=#{configuration_content.id}&metric_name=#{formatted_metric_name}"
    end
  end

  def remove_metric_configuration
    configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_name]
    Kalibro::Client::MetricConfigurationClient.new.remove(configuration_content.name, metric_name)
    redirect_to "/#{profile.identifier}/#{configuration_content.slug}"
  end

  private 

  def new_metric_configuration_instance
    metric_configuration = Kalibro::Entities::MetricConfiguration.new
    metric_configuration.metric = Kalibro::NativeMetric.new
    assign_metric_configuration_instance(metric_configuration, Kalibro::Entities::MetricConfiguration::NATIVE_TYPE)
  end
  
  def new_compound_metric_configuration_instance
    metric_configuration = Kalibro::Entities::MetricConfiguration.new
    metric_configuration.metric = Kalibro::Entities::CompoundMetric.new
    assign_metric_configuration_instance(metric_configuration, Kalibro::Entities::MetricConfiguration::COMPOUND_TYPE)
  end
  
  def assign_metric_configuration_instance(metric_configuration, type=Kalibro::Entities::MetricConfiguration::NATIVE_TYPE)
    metric_configuration.metric.name = params[:metric_configuration][:metric][:name]
    metric_configuration.metric.description = params[:metric_configuration][:metric][:description]
    metric_configuration.metric.scope = params[:metric_configuration][:metric][:scope]
    metric_configuration.code = params[:metric_configuration][:code]
    metric_configuration.weight = params[:metric_configuration][:weight]
    metric_configuration.aggregation_form = params[:metric_configuration][:aggregation_form]
    
    if type == Kalibro::Entities::MetricConfiguration::NATIVE_TYPE
      metric_configuration.metric.origin = params[:metric_configuration][:metric][:origin]
      metric_configuration.metric.language = params[:metric_configuration][:metric][:language]
    elsif type == Kalibro::Entities::MetricConfiguration::COMPOUND_TYPE
      metric_configuration.metric.script = params[:metric_configuration][:metric][:script]
    end
    metric_configuration
  end
  
  def generic_metric_configuration_creation(metric_configuration, configuration_name)
    Kalibro::Client::MetricConfigurationClient.new.save(metric_configuration, configuration_name)
    metric_configuration.metric.name
  end
  
  def auxiliar_update_metric_configuration(type)
    metric_name = params[:metric_configuration][:metric][:name]
    metric_configuration = Kalibro::Client::MetricConfigurationClient.metric_configuration(@configuration_content.name, metric_name)  
    metric_configuration = assign_metric_configuration_instance(metric_configuration, type)
    Kalibro::Client::MetricConfigurationClient.new.save(metric_configuration, @configuration_content.name)
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
