#TODO refatorar todo o controller e seus testes funcionais
class MezuroPluginProcessingController < MezuroPluginProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def render_last_state
    last_state = Kalibro::Processing.last_processing_state_of(params[:repository_id].to_i)
    render :text => last_state
  end

  def processing
    date = params[:date]
    repository_id = params[:repository_id].to_i
    processing_class = Kalibro::Processing
    @processing = date.nil? ? processing_class.processing_of(repository_id) : processing_class.processing_with_date_of(repository_id, date)
    if @processing.state == 'ERROR'
      render :partial => 'processing_error'
    else
      render :partial => 'processing'
    end
  end

end
