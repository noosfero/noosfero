class MezuroPluginProcessingController < MezuroPluginProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def state
    processing = processing_for_date(params[:repository_id].to_i, params[:date])
    render :text => processing.state
  end

  def processing
    @processing = processing_for_date(params[:repository_id].to_i, params[:date])
    if @processing.state == 'ERROR'
      render :partial => 'processing_error'
    else
      render :partial => 'processing'
    end
  end

  private

  def processing_for_date(repository_id, date = nil)
    processing_class = Kalibro::Processing
    if date.nil?
      processing_class.processing_of(repository_id)
    else
      processing_class.processing_with_date_of(repository_id, date)
    end
  end

end
