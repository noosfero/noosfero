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
    # force the solr tasks to run with each individual test task
    override_task test_task do
      ENV['RAILS_ENV'] = 'test'
      Rake::Task['solr:start'].reenable
      Rake::Task['solr:start'].invoke
      Rake::Task["#{orig_name}:original"].invoke
      Rake::Task['solr:stop'].reenable
      Rake::Task['solr:stop'].invoke
    end
  end
end
(CucumberTasks + NoosferoTasks).each do |test_task|
  override_task test_task do
    ENV['RAILS_ENV'] = 'test'
    Rake::Task['solr:start'].reenable
    Rake::Task['solr:start'].invoke
    Rake::Task["#{test_task}:original"].invoke
    Rake::Task['solr:stop'].reenable
    Rake::Task['solr:stop'].invoke
  end
end

task :test do
  errors = AllTasks.collect do |task|
    begin
      ENV['RAILS_ENV'] = 'test'
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    end
  end.compact
  abort "Errors running #{errors.to_sentence}!" if errors.any?
end

