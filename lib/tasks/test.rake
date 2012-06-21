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

task :test do
  errors = AllTasks.collect do |task|
    begin
      CucumberTasks.include?(task) ? ENV['RAILS_ENV'] = 'cucumber' : ENV['RAILS_ENV'] = 'test'
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    end
  end.compact
  abort "Errors running #{errors.to_sentence}!" if errors.any?
end

