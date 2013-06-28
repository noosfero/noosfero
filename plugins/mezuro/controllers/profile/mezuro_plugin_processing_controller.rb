class MezuroPluginProcessingController < MezuroPluginProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def state
    processing = processing_for_date(params[:repository_id].to_i, params[:date])
    if processing.error.nil?
      render :text => processing.state
    else
      render :text => 'ERROR'
    end
  end

  def processing
    @processing = processing_for_date(params[:repository_id].to_i, params[:date])
    if @processing.error.nil?
      render :partial => 'processing'
    else
      render :partial => 'processing_error'
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
