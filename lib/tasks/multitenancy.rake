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
    # enable output from rebuild_index
    logger = ActiveRecord::Base.logger = Logger.new(STDOUT)
    logger.level = ActiveSupport::BufferedLogger::INFO

    db_envs = ActiveRecord::Base.configurations.keys.select{ |k| k.match(/_#{RAILS_ENV}$/) }
    db_envs.each do |e|
      puts "Rebuilding index for environment #{e}"
      ActiveRecord::Base.connection.schema_search_path = ActiveRecord::Base.configurations[e]['schema_search_path']
      $solr_indexed_models.each do |m|
        puts "Rebuilding index for model #{m}"
        m.rebuild_index
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
