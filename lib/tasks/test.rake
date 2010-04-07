task :default => [:test, :cucumber, :selenium]

desc 'Runs Seleniun acceptance tests'
task :selenium do
  sh "xvfb-run cucumber -p selenium --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
end
