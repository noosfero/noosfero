def define_task(test, plugins_folder='plugins', plugin = '*')
  test_files = Dir.glob(File.join(Rails.root, plugins_folder, plugin, 'test', test[:folder], '**', '*_test.rb'))
  desc 'Runs ' + (plugin != '*' ? plugin : 'plugins') + ' ' + test[:name] + ' tests'
  Rake::TestTask.new(test[:name].to_sym) do |t|
    t.test_files = test_files
    t.verbose = true
  end
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

    task :units => 'available:units'
    task :functionals => 'available:functionals'
    task :integration => 'available:integration'
    task :available => [:units, :functionals, :integration]
    task :enabled => ['enabled:units', 'enabled:functionals', 'enabled:integration']

  end

  task :noosfero_plugins => 'noosfero_plugins:available'

end
