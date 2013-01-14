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

def run_tests(name, files_glob)
  files = Dir.glob(files_glob)
  if files.empty?
    puts "I: no tests to run (#{name})"
  else
    sh 'testrb', '-Itest', *files
  end
end

def run_cucumber(name, profile, files_glob)
  files = Dir.glob(files_glob)
  if files.empty?
    puts "I: no tests to run #{name}"
  else
    sh 'xvfb-run', 'ruby', '-S', 'cucumber', '--profile', profile.to_s, '--format', ENV['CUCUMBER_FORMAT'] || 'progress' , *files
  end
end

def plugin_test_task(name, plugin, files_glob)
  desc "Run #{name} tests for #{plugin_name(plugin)}"
  task name => 'db:test:plugins:prepare' do |t|
    run_tests t.name, files_glob
  end
end

def plugin_cucumber_task(name, plugin, files_glob)
  desc "Run #{name} tests for #{plugin_name(plugin)}"
  task name => 'db:test:plugins:prepare' do |t|
    run_cucumber t.name, :default, files_glob
  end
end

def plugin_selenium_task(name, plugin, files_glob)
  desc "Run #{name} tests for #{plugin_name(plugin)}"
  task name => 'db:test:plugins:prepare' do |t|
    run_cucumber t.name, :selenium, files_glob
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
        plugin_test_task :units, plugin, "plugins/#{plugin}/test/unit/**/*.rb"
        plugin_test_task :functionals, plugin, "plugins/#{plugin}/test/functional/**/*.rb"
        plugin_test_task :integration, plugin, "plugins/#{plugin}/test/integration/**/*.rb"
        plugin_cucumber_task :cucumber, plugin, "plugins/#{plugin}/test/features/**/*.feature"
        plugin_selenium_task :selenium, plugin, "plugins/#{plugin}/test/features/**/*.feature"
      end

      test_sequence_task(plugin, plugin, "#{plugin}:units", "#{plugin}:functionals", "#{plugin}:integration", "#{plugin}:cucumber", "#{plugin}:selenium")
    end

    { :units => :unit , :functionals => :functional , :integration => :integration }.each do |taskname,folder|
      task taskname => 'db:test:plugins:prepare' do |t|
        run_tests t.name, "plugins/{#{enabled_plugins.join(',')}}/test/#{folder}/**/*.rb"
      end
    end

    task :cucumber => 'db:test:plugins:prepare' do |t|
      run_cucumber t.name, :default, "plugins/{#{enabled_plugins.join(',')}}/test/features/**/*.features"
    end

    task :selenium => 'db:test:plugins:prepare' do |t|
      run_cucumber t.name, :selenium, "plugins/{#{enabled_plugins.join(',')}}/test/features/**/*.features"
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
