namespace :db do
  desc "Checks whether the database exists or not"
  task :exists do
    begin
      # Tries to initialize the application.
      # It will fail if the database does not exist
      Rake::Task["environment"].invoke
      ActiveRecord::Base.connection
    rescue
      exit 1
    else
      exit 0
    end
  end

  namespace :tables do
    task :exists do
      begin
        # It will fail if the table 'environments' does not exist
        Environment.count
      rescue
        exit 1
      else
        exit 0
      end
    end
  end
end
