namespace :jrails do

	namespace :assets do
		desc "Install javascript and css files for jquery and jqueryui"
		task :install do
			puts "Copying files..."
			project_dir = Rails.root + '/public/'
			plugin_assets_dir = File.join(File.dirname(__FILE__), '../..', 'assets/.')
			FileUtils.cp_r plugin_assets_dir, project_dir
			puts "files install succesfully"
		end

    desc 'Remove the prototype / script.aculo.us javascript files'
    task :scrub do
      puts "Removing files..."
      files = %W[controls.js dragdrop.js effects.js prototype.js]
      project_dir = File.join(Rails.root, 'public', 'javascripts')
      files.each do |fname|
        FileUtils.rm(File.join(project_dir, fname)) if File.exists?(File.join(project_dir, fname))
      end
      puts "files removed successfully."
    end
  end
  
end
