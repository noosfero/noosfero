plugins_root = Rails.env.test? ? 'plugins' : '{baseplugins,config/plugins}'
prefixes_by_folder = {public: 'plugin',
                      profile: 'profile/:profile/plugin',
                      myprofile: 'myprofile/:profile/plugin',
                      admin: 'admin/plugin'}

Dir.glob(Rails.root.join(plugins_root, '*', 'controllers')) do |controllers_dir|
  plugin_name = File.basename(File.dirname(controllers_dir))

  controllers_by_folder = prefixes_by_folder.keys.inject({}) do |hash, folder|
    path = "#{controllers_dir}/#{folder}/"
    hash[folder] = Dir.glob("#{path}{*.rb,#{plugin_name}_plugin/*.rb}").map do |filename|
      filename.gsub(path, '').gsub /[_\/]controller.rb$/, ''
    end
    hash
  end

  controllers_by_folder.each do |folder, controllers|
    controllers.each do |controller|
      controller_name = controller.gsub /#{plugin_name}_plugin[_\/]?/, ''
      controller_path = if controller_name.present? then "/#{controller_name}" else '' end
      as = controller.tr '/','_'
      if %w[profile myprofile].include?(folder.to_s)
        match "#{prefixes_by_folder[folder]}/#{plugin_name}#{controller_path}(/:action(/:id))",
          controller: controller, profile: /#{Noosfero.identifier_format}/i, via: :all, as: as
      else
        match "#{prefixes_by_folder[folder]}/#{plugin_name}#{controller_path}(/:action(/:id))",
          controller: controller, via: :all
      end
    end
  end

  match 'plugin/' + plugin_name + '(/:action(/:id))', controller: plugin_name + '_plugin', via: :all
  match "profile/:profile/plugin/#{plugin_name}(/:action(/:id))", controller: "#{plugin_name}_plugin_profile", profile: /#{Noosfero.identifier_format}/i, via: :all
  match "myprofile/:profile/plugin/#{plugin_name}(/:action(/:id))", controller: "#{plugin_name}_plugin_myprofile", profile: /#{Noosfero.identifier_format}/i, via: :all
  match 'admin/plugin/' + plugin_name + '(/:action(/:id))', controller: plugin_name + '_plugin_admin', via: :all
end
