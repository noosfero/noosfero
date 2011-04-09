t = Rake::Task[:test]
if t.respond_to?(:clear)
  t.clear
else
  t.prerequisites.clear
  t.instance_variable_get('@actions').clear
end

task :test do
  ENV['RAILS_ENV'] = 'test'
  Rake::Task['solr:stop'].invoke
  Rake::Task['solr:start'].invoke
  errors = %w(test:units test:functionals test:integration cucumber selenium).collect do |task|
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

desc 'Runs Seleniun acceptance tests'
task :selenium do
  sh "xvfb-run -a cucumber -p selenium --format #{ENV['CUCUMBER_FORMAT'] || 'progress'}"
end
