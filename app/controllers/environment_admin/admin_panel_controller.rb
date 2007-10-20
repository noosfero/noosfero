class AdminPanelController < EnvironmentAdminController

  protect [:index], 'view_environment_admin_panel', :environment

  before_filter :load_default_enviroment

  design :holder => 'environment'

  def load_default_enviroment
    @environment = Environment.default
  end

end
