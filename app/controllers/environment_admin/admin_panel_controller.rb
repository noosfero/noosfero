class AdminPanelController < EnvironmentAdminController
  protect [:index], 'view_environment_admin_panel', :environment

end
