class AdminPanelController < EnvironmentAdminController
  protect [:index], 'view_environment_admin_panel'

end
