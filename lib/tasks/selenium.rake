desc 'Runs Seleniun acceptance tests'
task :selenium do
  puts "Firefox version = #{`firefox --version`}"
  sh "xvfb-run -a --server-args=\"-screen 0, 1280x1024x24\" cucumber -p selenium --format #{ENV['CUCUMBER_FORMAT'] || 'progress'}"
end
