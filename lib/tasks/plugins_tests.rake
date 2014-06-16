@all_plugins = Dir.glob('plugins/*').map { |f| File.basename(f) } - ['template']
@all_tasks = [:units, :functionals, :integration, :cucumber, :selenium]

def enabled_plugins
  Dir.glob('config/plugins/*').map { |f| File.basename(f) } - ['README']
end

@original_enabled_plugins = enabled_plugins

def disabled_plugins
  @all_plugins - enabled_plugins
end

def enable_plugins(plugins = nil)
  if plugins == '*' || plugins.nil?
    sh './script/noosfero-plugins', '-q', 'enableall'
  else
    plugins = Array(plugins)
    sh './script/noosfero-plugins', '-q', 'enable', *plugins
  end
end

def disable_plugins(plugins = nil)
  if plugins == '*' || plugins.nil?
    sh './script/noosfero-plugins', '-q', 'disableall'
  else
    plugins = Array(plugins)
    sh './script/noosfero-plugins', '-q', 'disable', *plugins
  end
end

def rollback_plugins_state
  puts
  puts "==> Rolling back plugins to their original states..."
  disable_plugins
  enable_plugins(@original_enabled_plugins)
end

task 'db:test:plugins:prepare' do
  if Dir.glob('config/plugins/*/db/migrate/*.rb').empty?
    puts "I: skipping database setup, enabled plugins have no migrations"
  else
    Rake::Task['db:test:prepare'].execute
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

def test_sequence(plugins, tasks)
  failed = {}
  disable_plugins
  plugins = @all_plugins if plugins == '*'
  plugins = Array(plugins)
  tasks = Array(tasks)
  plugins.each do |plugin|
    failed[plugin] = []
    enable_plugins(plugin)
    next if !plugin_enabled?(plugin)
    begin
      Rake::Task['db:test:plugins:prepare' ].execute
    rescue Exception => ex
      failed[plugin] << :migration
    end
    tasks.each do |task|
      begin
        run_tests(task, plugin)
      rescue Exception => ex
        puts ex
        failed[plugin] << task
      end
    end
    disable_plugins(plugin)
  end
  fail_flag = false
  failed.each do |plugin, tasks|
    unless tasks.empty?
      puts "Tests failed on #{plugin} plugin: #{tasks.join(', ')}"
      fail_flag = true
    end
  end
  rollback_plugins_state
  fail 'There are broken tests to be fixed!' if fail_flag
end

def plugin_test_task(plugin, task, run=:individually)
  desc "Run #{task} tests for #{plugin_name(plugin)}"
  task task do
    test_sequence(plugin, task)
  end
end

namespace :test do
  namespace :noosfero_plugins do
    @all_plugins.each do |plugin|
      namespace plugin do
        @all_tasks.each do |taskname|
          plugin_test_task plugin, taskname
        end
      end

      desc "Run all tests for #{plugin_name(plugin)}"
      task plugin do
        test_sequence([plugin], @all_tasks)
      end
    end

    @all_tasks.each do |taskname|
      desc "Run #{taskname} tests for all plugins"
      task taskname do
        test_sequence(@all_plugins, taskname)
      end
    end
  end

  desc "Run all tests for all plugins"
  task :noosfero_plugins do
    test_sequence(@all_plugins, @all_tasks)
  end
end
