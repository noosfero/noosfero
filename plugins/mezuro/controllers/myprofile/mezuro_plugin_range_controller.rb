class MezuroPluginRangeController < MezuroPluginMyprofileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def new
    @content_id = params[:id].to_i
    @metric_configuration_id = params[:metric_configuration_id].to_i
    @reading_labels_and_ids = reading_labels_and_ids
  end

  def edit
    @content_id = params[:id].to_i
    @metric_configuration_id = params[:metric_configuration_id].to_i
    ranges = Kalibro::Range.ranges_of params[:metric_configuration_id].to_i
    @range = (ranges.select { |range| range.id == params[:range_id].to_i }).first
    @reading_labels_and_ids = reading_labels_and_ids
  end

  def create
    metric_configuration_id = params[:metric_configuration_id].to_i
    @range = Kalibro::Range.new params[:range]
    @range.save metric_configuration_id
    if !@range.errors.empty?
      @error = @range.errors[0].message
    end
  end

  def update
    metric_configuration_id = params[:metric_configuration_id].to_i
    @range = Kalibro::Range.new params[:range]
    @range.save metric_configuration_id
    if !@range.errors.empty?
      @error = @range.errors[0].message
    end
  end

  def remove
    configuration_content_id = params[:id].to_i
    metric_configuration_id = params[:metric_configuration_id].to_i
    compound = params[:compound]
    Kalibro::Range.new({:id => params[:range_id].to_i}).destroy
    if compound
      redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/metric_configuration/edit_compound?id=#{configuration_content_id}&metric_configuration_id=#{metric_configuration_id}"
    else
      redirect_to "/myprofile/#{profile.identifier}/plugin/mezuro/metric_configuration/edit_native?id=#{configuration_content_id}&metric_configuration_id=#{metric_configuration_id}"
    end
  end

  private

  def reading_labels_and_ids
    array = Kalibro::Reading.readings_of(params[:reading_group_id].to_i).map { |reading| [reading.label, reading.id] }
    array.sort { |x,y| x.first.downcase <=> y.first.downcase }
  end

end
