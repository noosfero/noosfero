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
    orig_name = test_task.to_s
    test_task = test_task.to_s.gsub(/^test:/, '').to_sym #remove namespace :test    
    ENV['RAILS_ENV'] = 'test'
    # force the solr tasks to run with each individual test task
    override_task test_task do
      Rake::Task['solr:start'].execute
      Rake::Task["#{orig_name}:original"].execute
      Rake::Task['solr:stop'].execute
    end
  end
end
(CucumberTasks + NoosferoTasks).each do |test_task|
  ENV['RAILS_ENV'] = 'test'
  override_task test_task do
    Rake::Task['solr:start'].execute
    Rake::Task["#{test_task}:original"].execute
    Rake::Task['solr:stop'].execute
  end
end

task :test do
  ENV['RAILS_ENV'] = 'test'
  errors = AllTasks.collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    end
  end.compact
  abort "Errors running #{errors.to_sentence}!" if errors.any?
end

