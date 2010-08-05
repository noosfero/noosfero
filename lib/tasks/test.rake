Rake::Task[:test].clear

task :test do
  errors = %w(test:units test:functionals test:integration cucumber selenium).collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      task
    end
  end.compact
  abort "Errors running #{errors.to_sentence}!" if errors.any?
end

desc 'Runs Seleniun acceptance tests'
task :selenium do
  sh "xvfb-run cucumber -p selenium --format #{ENV['CUCUMBER_FORMAT'] || 'progress'}"
end
