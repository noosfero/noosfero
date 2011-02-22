Dir.glob(File.join(Rails.root, 'config', 'plugins', '*', 'controllers')) do |dir|
  plugin_name = File.basename(File.dirname(dir))
  map.connect 'plugin/' + plugin_name + '/:action/:id', :controller => plugin_name + '_plugin_environment'
  map.connect 'profile/:profile/plugins/' + plugin_name + '/:action/:id', :controller => plugin_name + '_plugin_profile'
  map.connect 'myprofile/:profile/plugin/' + plugin_name + '/:action/:id', :controller => plugin_name + '_plugin_myprofile'
  map.connect 'admin/plugin/' + plugin_name + '/:action/:id', :controller => plugin_name + '_plugin_admin'
end

