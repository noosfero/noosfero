namespace :multitenancy do

  task :create do
    db_envs = ActiveRecord::Base.configurations.keys.select{ |k| k.match(/_development$|_production$|_test$/) }
    cd File.join(RAILS_ROOT, 'config', 'environments'), :verbose => true
    file_envs = Dir.glob "{*_development.rb,*_prodution.rb,*_test.rb}"
    (db_envs.map{ |e| e + '.rb' } - file_envs).each { |env| ln_s env.split('_').last, env }
  end

  task :remove do
    db_envs = ActiveRecord::Base.configurations.keys.select{ |k| k.match(/_development$|_production$|_test$/) }
    cd File.join(RAILS_ROOT, 'config', 'environments'), :verbose => true
    file_envs = Dir.glob "{*_development.rb,*_prodution.rb,*_test.rb}"
    (file_envs - db_envs.map{ |e| e + '.rb' }).each { |env| safe_unlink env }
  end

  task :reindex => :environment do
    envs = ActiveRecord::Base.configurations.keys.select{ |k| k.match(/_#{RAILS_ENV}$/) }
    models = [ Profile, Article, Product ]
    envs.each do |e|
      puts "Rebuilding Index for #{e}" if Rake.application.options.trace
      ActiveRecord::Base.connection.schema_search_path = ActiveRecord::Base.configurations[e]['schema_search_path']
      models.each do |m|
        if e == envs[0]
          m.rebuild_index
          puts "Rebuilt index for #{m}" if Rake.application.options.trace
        end
        m.paginated_each(:per_page => 50) { |i| i.ferret_update }
        puts "Reindexed all instances of #{m}" if Rake.application.options.trace
      end
    end
  end

end

namespace :db do

  task :migrate_other_environments => :environment do
    envs = ActiveRecord::Base.configurations.keys.select{ |k| k.match(/_#{RAILS_ENV}$/) }
    envs.each do |e|
      puts "*** Migrating #{e}" if Rake.application.options.trace
      system "rake db:migrate RAILS_ENV=#{e}"
    end
  end
  task :migrate => :migrate_other_environments

end
