class EnterpriseValidationController < ProfileAdminController

  def index
    @pending_validations = profile.pending_validations
  end

  def details
    @pending = profile.find_pending_validation(params[:id])
    unless @pending
      render_not_found
    end
  end

  post_only :approve
  def approve
    @pending = profile.find_pending_validation(params[:id])
    if @pending
      @pending.approve
      redirect_to :action => 'view_processed', :id => @pending.code
    else
      render_not_found
    end
  end

  post_only :reject
  def reject
    @pending = profile.find_pending_validation(params[:id])
    @pending.reject_explanation = params[:reject_explanation]
    if @pending 
      @pending.reject
      redirect_to :action => 'view_processed', :id => @pending.code
    else
      render_not_found
    end
  end

  def list_processed
    @processed_validations = profile.processed_validations
  end

  def view_processed
    @processed = profile.find_processed_validation(params[:id])
    unless @processed
      render_not_found
    end
  end

end
