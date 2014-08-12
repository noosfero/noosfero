
desc "Default Task"
task :default => [:test]

desc "Runs the unit tests"
task :test => "test:unit"

namespace :test do

  task :migrate do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migrator.migrate("test/db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end

  task :setup do
    DB ||= 'sqlite'
    puts "Using " + DB
    %x(mysql -u#{MYSQL_USER} < #{File.dirname(__FILE__) + "/test/fixtures/db_definitions/mysql.sql"}) if DB == 'mysql'

    Rake::Task["test:migrate"].invoke
  end

  desc 'Measures test coverage using rcov'
  task :rcov => :setup do
    rm_f "coverage"
    rm_f "coverage.data"
    rcov = "rcov --rails --aggregate coverage.data --text-summary -Ilib"

    system("#{rcov} --html #{Dir.glob('test/**/*_shoulda.rb').join(' ')}")
    system("open coverage/index.html") if PLATFORM['darwin']
  end

  desc 'Runs the functional tests, testing integration with Solr'
  Rake::TestTask.new(:functional => :setup) do |t|
    t.pattern = "test/functional/*_test.rb"
    t.verbose = true
  end

  desc "Unit tests"
  Rake::TestTask.new(:unit => :setup) do |t|
    t.libs << 'test/unit'
    t.pattern = "test/unit/*_shoulda.rb"
    t.verbose = true
  end
end
