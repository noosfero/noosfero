class PluginAdminController < AdminController

  protect 'edit_environment_features', :environment

end
