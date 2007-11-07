class EnterpriseValidationController < ProfileAdminController

  def index
    @pending_validations = profile.pending_validations
  end

  def details
    @pending = profile.pending_validations(:code => params[:id]).first
    unless @pending
      render_not_found
    end
  end

end
