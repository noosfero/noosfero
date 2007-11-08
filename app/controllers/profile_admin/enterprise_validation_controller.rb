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

end
