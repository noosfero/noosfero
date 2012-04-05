@disabled_plugins = Dir.glob(File.join(Rails.root, 'plugins', '*')).map { |file| File.basename(file)} - Dir.glob(File.join(Rails.root, 'config', 'plugins', '*')).map { |file| File.basename(file)}
@disabled_plugins.delete('template')

def define_task(test, plugins_folder='plugins', plugin = '*')
  test_files = Dir.glob(File.join(Rails.root, plugins_folder, plugin, 'test', test[:folder], '**', '*_test.rb'))
  desc 'Runs ' + (plugin != '*' ? plugin : 'plugins') + ' ' + test[:name] + ' tests'
  Rake::TestTask.new(test[:name].to_sym => 'db:test:plugins:prepare') do |t|
    t.libs << 'test'
    t.test_files = test_files
    t.verbose = true
  end
end

task 'db:test:plugins:prepare' do
  Rake::Task['db:test:prepare'].invoke
  sh 'rake db:migrate RAILS_ENV=test SCHEMA=/dev/null'
end

namespace :test do
  namespace :noosfero_plugins do
    tasks = [
      {:name => :available, :folder => 'plugins'},
      {:name => :enabled, :folder => File.join('config', 'plugins')}
    ]
    tests = [
      {:name => 'units', :folder => 'unit'},
      {:name => 'functionals', :folder => 'functional'},
      {:name => 'integration', :folder => 'integration'}
    ]

    tasks.each do |t|
      namespace t[:name] do
        tests.each do |test|
          define_task(test, t[:folder])
        end
      end
    end

    plugins = Dir.glob(File.join(Rails.root, 'plugins', '*')).map {|path| File.basename(path)}

    plugins.each do |plugin_name|
      namespace plugin_name do
        tests.each do |test|
          define_task(test, 'plugins', plugin_name)
        end
      end

      dependencies = []
      tests.each do |test|
        dependencies << plugin_name+':'+test[:name]
      end
      task plugin_name => dependencies
    end

    task :temp_enable_plugins do
      system('./script/noosfero-plugins enableall')
    end

    task :rollback_temp_enable_plugins do
      @disabled_plugins.each { |plugin| system('./script/noosfero-plugins disable ' + plugin)}
    end

    task :units => 'available:units'
    task :functionals => 'available:functionals'
    task :integration => 'available:integration'
    task :available do
      Rake::Task['test:noosfero_plugins:temp_enable_plugins'].invoke
      begin
        Rake::Task['test:noosfero_plugins:units'].invoke
        Rake::Task['test:noosfero_plugins:functionals'].invoke
        Rake::Task['test:noosfero_plugins:integration'].invoke
      rescue
      end
      Rake::Task['test:noosfero_plugins:rollback_temp_enable_plugins'].invoke
    end
    task :enabled => ['enabled:units', 'enabled:functionals', 'enabled:integration']


    namespace :cucumber do
      task :enabled do
        features = Dir.glob('config/plugins/*/features/*.feature')
        if features.empty?
          puts "No acceptance tests for enabled plugins, skipping"
        else
          ruby '-S', 'cucumber', '--format', ENV['CUCUMBER_FORMAT'] || 'progress' , *features
        end
      end
    end

    namespace :selenium do
      task :enabled do
        features = Dir.glob('config/plugins/*/features/*.feature')
        if features.empty?
          puts "No acceptance tests for enabled plugins, skipping"
        else
          sh 'xvfb-run', 'ruby', '-S', 'cucumber', '--profile', 'selenium', '--format', ENV['CUCUMBER_FORMAT'] || 'progress' , *features
        end
      end
    end

  end

  task :noosfero_plugins => %w[ noosfero_plugins:available noosfero_plugins:cucumber:enabled noosfero_plugins:selenium:enabled ]

end

