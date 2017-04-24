require 'rspec/core/rake_task'

namespace :test do
  desc "Run the API tests in test/api"
  Rake::TestTask.new api: 'db:test:prepare' do |t|
    t.libs << 'test'
    t.pattern = 'test/api/**/*_test.rb'
    t.warning = false
  end

  desc "Run the Rspec tests"
  RSpec::Core::RakeTask.new :specs
  
  desc "Run the tests to take coverage"
  Rake::TestTask.new 'coverage' do |t|
    puts 'iniciou os testes...'
#    ENV['COVERAGE'] = true
#    Rake::Task[:api].invoke
#    Rake::Task[:test:units].invoke
#    t.libs << 'test'
#    t.pattern = 'test/api/**/*_test.rb'
#    t.warning = false
  end

end

#Rake::Task[:coverage].enhance ['test', 'cucumber', 'selenium']
