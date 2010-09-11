class ActionTrackerGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migration.rb', File.join('db', 'migrate'), :migration_file_name => 'create_action_tracker'
    end
  end
end
