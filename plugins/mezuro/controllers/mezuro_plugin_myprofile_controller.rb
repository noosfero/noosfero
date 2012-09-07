class MezuroPluginMyprofileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  rescue_from Exception do |exception|
    message = URI.escape(CGI.escape(exception.message),'.')
    redirect_to_error_page message
  end

  def error_page
    @message = params[:message]
  end

  def choose_base_tool
    @configuration_content = profile.articles.find(params[:id])
    @base_tools = Kalibro::BaseTool.all_names
  end

  def choose_metric
    @configuration_content = profile.articles.find(params[:id])
    @base_tool = params[:base_tool]
    base_tool = Kalibro::BaseTool.find_by_name(@base_tool)
    @supported_metrics = base_tool.nil? ? [] : base_tool.supported_metrics 
  end

  def new_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric = Kalibro::BaseTool.find_by_name(params[:base_tool]).metric params[:metric_name]
  end

  def new_compound_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric_configurations = @configuration_content.metric_configurations
    if configuration_content_has_errors?
      redirect_to_error_page @configuration_content.errors[:base]
    end
  end

  def edit_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, params[:metric_name])
    @metric = @metric_configuration.metric
  end

  def edit_compound_metric_configuration
    @configuration_content = profile.articles.find(params[:id])
    @metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, params[:metric_name])
    @metric_configurations = @configuration_content.metric_configurations
    @metric = @metric_configuration.metric
  end

  def create_metric_configuration
    id = params[:id]
    metric_name = params[:metric_configuration][:metric][:name]
    metric_configuration = Kalibro::MetricConfiguration.new(params[:metric_configuration])
    metric_configuration.save
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    else
      redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_metric_configuration?id=#{id}&metric_name=#{metric_name.gsub(/\s/, '+')}"
    end
  end

  def create_compound_metric_configuration
    id = params[:id]
    metric_name = params[:metric_configuration][:metric][:name]
    metric_configuration = Kalibro::MetricConfiguration.new(params[:metric_configuration])
    metric_configuration.save
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    else
      redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_compound_metric_configuration?id=#{id}&metric_name=#{metric_name.gsub(/\s/, '+')}"
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

  def new_range
    @configuration_content = profile.articles.find(params[:id])
    @metric_name = params[:metric_name]
    @range = Kalibro::Range.new
    @range_color = "#000000"
  end

  def edit_range
    @configuration_content = profile.articles.find(params[:id])
    @metric_name = params[:metric_name]
    @beginning_id = params[:beginning_id]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, @metric_name)
    @range = metric_configuration.ranges.find{|range| range.beginning == @beginning_id.to_f || @beginning_id =="-INF" }
    @range_color = "#" + @range.color.to_s.gsub(/^ff/, "")
  end

  def create_range
    @configuration_content = profile.articles.find(params[:id])
    @range = Kalibro::Range.new params[:range]
    metric_name = params[:metric_name]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(@configuration_content.name, metric_name)
    metric_configuration.add_range(@range)
    metric_configuration.save
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    end
  end

  def update_range
    configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_name]
    beginning_id = params[:beginning_id]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(configuration_content.name, metric_name)
    index = metric_configuration.ranges.index{ |range| range.beginning == beginning_id.to_f || beginning_id == "-INF" }
    metric_configuration.ranges[index] = Kalibro::Range.new params[:range]
    metric_configuration.save
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    end
  end

  def remove_range
    configuration_content = profile.articles.find(params[:id])
    metric_name = params[:metric_name]
    beginning_id = params[:beginning_id]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(configuration_content.name, metric_name)
    metric_configuration.ranges.delete_if { |range| range.beginning == beginning_id.to_f || beginning_id == "-INF" }
    metric_configuration.save
    if metric_configuration_has_errors? metric_configuration
      redirect_to_error_page metric_configuration.errors[0].message
    else
      formatted_metric_name = metric_name.gsub(/\s/, '+')
      if metric_configuration.metric.class == Kalibro::CompoundMetric
        redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_compound_metric_configuration?id=#{configuration_content.id}&metric_name=#{formatted_metric_name}"
      else
        redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/edit_metric_configuration?id=#{configuration_content.id}&metric_name=#{formatted_metric_name}"
      end
    end
  end

  private

  def redirect_to_error_page(message)
    message = URI.escape(CGI.escape(message),'.')
    redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/error_page?message=#{message}"
  end

  def configuration_content_has_errors?
    not @configuration_content.errors[:base].nil?
  end

  def metric_configuration_has_errors? metric_configuration
    not metric_configuration.errors.empty?
  end

end
