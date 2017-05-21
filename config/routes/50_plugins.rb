paths              = {}
profile_format     = /#{Noosfero.identifier_format}/i
plugins_root       = if Rails.env.test? then 'plugins' else '{baseplugins,config/plugins}' end
prefixes_by_folder = {
  public:    'plugin',
  profile:   'profile/:profile/plugin',
  myprofile: 'myprofile/:profile/plugin',
  admin:     'admin/plugin',
}

Dir.glob Rails.root.join plugins_root, '*', 'controllers' do |controllers_dir|
  plugin_name = File.basename File.dirname controllers_dir

  controllers_by_folder = prefixes_by_folder.keys.inject({}) do |hash, folder|
    path = "#{controllers_dir}/#{folder}/"
    hash[folder] = Dir.glob("#{path}{*.rb,#{plugin_name}_plugin/*.rb}").map do |filename|
      filename.gsub(path, '').gsub(/[_\/]controller.rb$/, '')
    end
    hash
  end


  controllers_by_folder.each do |folder, controllers|
    controllers.each do |controller|
      controller_name = controller.gsub(/#{plugin_name}_plugin[_\/]?/, '')
      controller_path = if controller_name.present? then "/#{controller_name}" else '' end

      as  = controller.tr '/','_'
      url = "#{prefixes_by_folder[folder]}/#{plugin_name}#{controller_path}(/:action(/:id))"

      paths[url] = {
        controller: controller,
        via:        :all,
        as:         as,
      }
      paths[url][:profile] = profile_format if folder.to_s.in? %w[profile myprofile]
    end
  end

  # DEPRECATED default controllers
  paths.reverse_merge!(
    "plugin/#{plugin_name}(/:action(/:id))" => {
      controller: "#{plugin_name}_plugin",
      via:        :all,
    },
    "admin/plugin/#{plugin_name}(/:action(/:id))" => {
      controller: "#{plugin_name}_plugin_admin",
      via:        :all,
    },

    "profile/:profile/plugin/#{plugin_name}(/:action(/:id))" => {
      controller: "#{plugin_name}_plugin_profile",
      via:        :all,
      profile:    profile_format,
    },
    "myprofile/:profile/plugin/#{plugin_name}(/:action(/:id))" => {
      controller: "#{plugin_name}_plugin_myprofile",
      via:        :all,
      profile:    profile_format,
    },
  )
end

Noosfero::Application.routes.draw do

  paths.each do |url, opts|
    controller_klass = "#{opts[:controller]}_controller".camelize.constantize rescue nil
    next unless controller_klass

    match url, opts
  end

end
