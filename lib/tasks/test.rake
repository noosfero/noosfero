t = Rake::Task[:test]
if t.respond_to?(:clear)
  t.clear
else
  t.prerequisites.clear
  t.instance_variable_get('@actions').clear
end

desc 'Runs Seleniun acceptance tests'
task :selenium do
  sh "xvfb-run -a cucumber -p selenium --format #{ENV['CUCUMBER_FORMAT'] || 'progress'}"
end

TestTasks = %w(test:units test:functionals test:integration)
CucumberTasks = %w(cucumber selenium)
NoosferoTasks = %w(test:noosfero_plugins)
AllTasks = TestTasks + CucumberTasks + NoosferoTasks

namespace :test do
  TestTasks.each do |test_task|
    test_task = test_task.to_s.gsub(/^test:/, '').to_sym #remove namespace :test
    ENV['RAILS_ENV'] = 'test'
    override_task test_task => ['solr:start', "#{test_task}:original", "solr:stop"]
  end
end
(CucumberTasks + NoosferoTasks).each do |test_task|
  ENV['RAILS_ENV'] = 'test'
  override_task test_task => ['solr:start', "#{test_task}:original", "solr:stop"]
end

task :test do
  ENV['RAILS_ENV'] = 'test'
  Rake::Task['solr:start'].invoke
  errors = AllTasks.collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    end
  end.compact
  Rake::Task['solr:stop'].invoke
  abort "Errors running #{errors.to_sentence}!" if errors.any?
end

