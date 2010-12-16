namespace :plugins do
  task :migrate do
    Dir.glob(File.join(Rails.root, 'config', 'plugins', '*', 'db', 'migrate')).each do |path|
      ActiveRecord::Migrator.migrate(path, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end
  end
end

task 'db:migrate' => 'plugins:migrate'
