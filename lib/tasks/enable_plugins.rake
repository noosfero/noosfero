namespace :noosfero do
  namespace :plugins do
    task :enable_all => :environment do
      Environment.all.each do |env|
        puts "Plugins Activated on #{env.name}" if env.enable_all_plugins
      end
    end
  end
end
