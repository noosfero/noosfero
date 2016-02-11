desc 'Runs Seleniun acceptance tests'
task :selenium do
  puts "Firefox version = #{`firefox --version`}"
  sh "xvfb-run -a cucumber -p selenium --format #{ENV['CUCUMBER_FORMAT'] || 'progress'}"
end
