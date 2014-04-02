all_plugins = Dir.glob('plugins/*').map { |f| File.basename(f) } - ['template']
def enabled_plugins
  Dir.glob('config/plugins/*').map { |f| File.basename(f) } - ['README']
end
disabled_plugins = all_plugins - enabled_plugins

task 'db:test:plugins:prepare' do
  if Dir.glob('config/plugins/*/db/migrate/*.rb').empty?
    puts "I: skipping database setup, enabled plugins have no migrations"
  else
    Rake::Task['db:test:prepare'].invoke
    sh 'rake db:migrate RAILS_ENV=test SCHEMA=/dev/null'
  end
end

def plugin_name(plugin)
  "#{plugin} plugin"
end

def plugin_enabled?(plugin)
  File.exist?(File.join('config', 'plugins', plugin))
end

def plugin_disabled_warning(plugin)
  puts "E: you should enable #{plugin} plugin before running it's tests!"
end

def task2ext(task)
  (task == :selenium || task == :cucumber) ? :feature : :rb
end

def task2profile(task, plugin)
  if task == :cucumber
    return plugin
  elsif task == :selenium
    return "#{plugin}_selenium"
  else
    return 'default'
  end
end

def filename2plugin(filename)
  filename.split('/')[1]
end

def task2folder(task)
  result = case task.to_sym
  when :units
    :unit
  when :functionals
    :functional
  when :integration
    :integration
  when :cucumber
    :features
  when :selenium
    :features
  end

  return result
end

def run_test(name, files)
  files = Array(files)
  plugin = filename2plugin(files.first)
  if name == :cucumber || name == :selenium
    run_cucumber task2_profile(name, plugin), files
  else
    run_testrb files
  end
end

def run_testrb(files)
  sh 'testrb', '-Itest', *files
end

def run_cucumber(profile, files)
  sh 'xvfb-run', 'ruby', '-S', 'cucumber', '--profile', profile.to_s, '--format', ENV['CUCUMBER_FORMAT'] || 'progress' , *files
end

def custom_run(name, files, run=:individually)
  case run
  when :all
    run_test name, files
  when :individually
    files.each do |file|
      run_test name, file
    end
  when :by_plugin
  end
end

def run_tests(name, plugins, run=:individually)
  plugins = Array(plugins)
  glob =  "plugins/{#{plugins.join(',')}}/test/#{task2folder(name)}/**/*.#{task2ext(name)}"
  files = Dir.glob(glob)
  if files.empty?
    puts "I: no tests to run #{name}"
  else
    custom_run(name, files, run)
  end
end

def plugin_test_task(name, plugin, run=:individually)
  desc "Run #{name} tests for #{plugin_name(plugin)}"
  task name => 'db:test:plugins:prepare' do |t|
    if plugin_enabled?(plugin)
      run_tests(name, plugin, run)
    else
      plugin_disabled_warning(plugin)
    end
  end
end

def test_sequence_task(name, plugin, *tasks)
  desc "Run all tests for #{plugin_name(plugin)}"
  task name do
    failed = []
    tasks.each do |task|
      begin
        Rake::Task['test:noosfero_plugins:' + task.to_s].invoke
      rescue Exception => ex
        puts ex
        failed << task
      end
    end
    unless failed.empty?
      fail 'Tests failed: ' + failed.join(', ')
    end
  end
end

namespace :test do
  namespace :noosfero_plugins do
    all_plugins.each do |plugin|
      namespace plugin do
        plugin_test_task :units, plugin
        plugin_test_task :functionals, plugin
        plugin_test_task :integration, plugin
        plugin_test_task :cucumber, plugin
        plugin_test_task :selenium, plugin
      end

      test_sequence_task(plugin, plugin, "#{plugin}:units", "#{plugin}:functionals", "#{plugin}:integration", "#{plugin}:cucumber", "#{plugin}:selenium")
    end

    [:units, :functionals, :integration].each do |taskname|
      task taskname => 'db:test:plugins:prepare' do |t|
        run_tests taskname, enabled_plugins
      end
    end

    task :cucumber => 'db:test:plugins:prepare' do |t|
      run_tests :cucumber, enabled_plugins
    end

    task :selenium => 'db:test:plugins:prepare' do |t|
      run_tests :selenium, enabled_plugins
    end

    task :temp_enable_all_plugins do
      sh './script/noosfero-plugins', 'enableall'
    end

    task :rollback_enable_all_plugins do
      sh './script/noosfero-plugins', 'disable', *disabled_plugins
    end
  end

  test_sequence_task(:noosfero_plugins, '*', :temp_enable_all_plugins, :units, :functionals, :integration, :cucumber, :selenium, :rollback_enable_all_plugins)

end
