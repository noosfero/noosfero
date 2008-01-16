class AdminPanelController < AdminController

  before_filter :login_required
  
  protect 'view_environment_admin_panel', :environment

  #FIXME This is not necessary because the application controller define the envrioment 
  # as the default holder
  before_filter :load_default_enviroment

  def boxes_holder
    environment
  end

  protected

  def load_default_enviroment
    @environment = Environment.default
  end
end
