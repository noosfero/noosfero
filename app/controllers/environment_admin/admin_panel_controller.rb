class AdminPanelController < EnvironmentAdminController

  protect [:index], 'view_environment_admin_panel', :environment

  design :holder => 'environment'

  before_filter :load_default_enviroment

  def load_default_enviroment
    Environment.default
  end

end
