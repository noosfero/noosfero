class MezuroPluginRangeController < MezuroPluginMyprofileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def new
    params_to_range_form
    params_to_redirect
  end

  def edit
    params_to_range_form
    ranges = Kalibro::Range.ranges_of params[:metric_configuration_id].to_i
    @range = (ranges.select { |range| range.id == params[:range_id].to_i }).first
  end

  def create
    params_to_redirect
    save_range
  end

  def update
    save_range
  end

  def remove
    configuration_content = profile.articles.find(params[:id])
    Kalibro::Range.new({:id => params[:range_id].to_i}).destroy
    redirect_to(metric_configuration_url(configuration_content))
  end

  private

  def metric_configuration_url configuration_content
    url = configuration_content.view_url
    url[:controller] = "mezuro_plugin_metric_configuration"
    url[:id] = configuration_content.id
    url[:metric_configuration_id] = params[:metric_configuration_id].to_i
    url[:action] = (params[:compound] ? "edit_compound" : "edit_native")
    url
  end

  def reading_labels_and_ids
    Kalibro::Reading.readings_of(params[:reading_group_id].to_i).map { |reading| [reading.label, reading.id] }
  end

  def save_range
    metric_configuration_id = params[:metric_configuration_id].to_i
    @range = Kalibro::Range.new params[:range]
    @range.save metric_configuration_id
    if !@range.errors.empty?
      @error = @range.errors[0].message
    end
  end

  def params_to_range_form
    @content_id = params[:id].to_i
    @metric_configuration_id = params[:metric_configuration_id].to_i
    @reading_labels_and_ids = reading_labels_and_ids
  end

  def params_to_redirect
    @reading_group_id = params[:reading_group_id].to_i
    @compound = params[:compound]
  end

end
