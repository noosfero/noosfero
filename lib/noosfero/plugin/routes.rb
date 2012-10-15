plugins_root = Rails.env.test? ? 'plugins' : File.join('config', 'plugins')

Dir.glob(File.join(Rails.root, plugins_root, '*', 'controllers')) do |controllers_dir|
  prefixes_by_folder = {'public' => 'plugin',
                        'profile' => 'profile/:profile/plugin',
                        'myprofile' => 'myprofile/:profile/plugin',
                        'admin' => 'admin/plugin'}

  controllers_by_folder = prefixes_by_folder.keys.inject({}) do |hash, folder|
    hash.merge!({folder => Dir.glob(File.join(controllers_dir, folder, '*')).map {|full_names| File.basename(full_names).gsub(/_controller.rb$/,'')}})
  end

  plugin_name = File.basename(File.dirname(controllers_dir))

  controllers_by_folder.each do |folder, controllers|
    controllers.each do |controller|
      controller_name = controller.gsub("#{plugin_name}_plugin_",'')
      map.connect "#{prefixes_by_folder[folder]}/#{plugin_name}/#{controller_name}/:action/:id", :controller => controller
    end
  end

  map.connect 'plugin/' + plugin_name + '/:action/:id', :controller => plugin_name + '_plugin'
  map.connect 'profile/:profile/plugin/' + plugin_name + '/:action/:id', :controller => plugin_name + '_plugin_profile'
  map.connect 'myprofile/:profile/plugin/' + plugin_name + '/:action/:id', :controller => plugin_name + '_plugin_myprofile'
  map.connect 'admin/plugin/' + plugin_name + '/:action/:id', :controller => plugin_name + '_plugin_admin'
end
