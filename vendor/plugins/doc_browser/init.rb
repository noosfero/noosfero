if ENV['RAILS_ENV'] == 'development'
  controllers_path = File.join(File.dirname(__FILE__), 'controllers')
  $LOAD_PATH << controllers_path
  Dependencies.load_paths << controllers_path
  config.controller_paths << controllers_path
end
