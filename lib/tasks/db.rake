namespace :db do
  desc "Checks whether the database exists or not"
  task :exists do
    begin
      # Tries to initialize the application.
      # It will fail if the database does not exist
      Rake::Task['environment'].invoke
    rescue
      exit 1
    else
      exit 0
    end
  end
end
