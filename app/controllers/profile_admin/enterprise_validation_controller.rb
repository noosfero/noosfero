class EnterpriseValidationController < ProfileAdminController

  def index
    #@pending = profile.pending_validations
    render :text => profile.inspect
  end

end
