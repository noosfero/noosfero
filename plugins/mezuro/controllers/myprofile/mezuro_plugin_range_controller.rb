class MezuroPluginRangeController < MezuroPluginMyprofileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def new_range
    @content_id = params[:id]
    @metric_name = params[:metric_name]
    @range = Kalibro::Range.new
    @range_color = "#000000"
  end

  def edit_range
    @beginning_id = params[:beginning_id]
    @content_id = params[:id]
    configuration_name = profile.articles.find(@content_id).name
    @metric_name = params[:metric_name]
    metric_configuration = Kalibro::MetricConfiguration.find_by_configuration_name_and_metric_name(configuration_name, @metric_name)
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

end
