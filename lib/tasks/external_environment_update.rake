namespace :external_environment do
 desc 'Task to import external environments'
   task :update do
     sh 'rails', 'runner', 'ExternalEnvironmentUpdater::process_data'
     puts 'External environments are up to date'
   end
end
