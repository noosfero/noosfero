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
  data = []
  failed = []
  AllTasks.each do |task|
    t0 = Time.now.to_i
    begin
      ENV['RAILS_ENV'] = 'test'
      Rake::Task[task].invoke
      status = 'PASS'
    rescue => e
      failed << task
      status = 'FAIL'
    end
    t1 = Time.now.to_i
    duration = t1 - t0
    data << { :name => task, :status => status, :duration => Time.at(duration).utc.strftime("%H:%M:%S") }
  end

  puts
  printf "%-30s %-6s %s\n", 'Task', 'Status', 'Duration'
  printf "%-30s %-6s %s\n", '-' * 30, '-' * 6, '--------'
  data.each do |entry|
    printf "%-30s %-6s %s\n", entry[:name], entry[:status], entry[:duration]
  end

  puts
  abort "Errors running #{failed.join(', ')}!" if failed.any?
end

