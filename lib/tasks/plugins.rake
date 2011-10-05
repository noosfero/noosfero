ActiveRecord::SchemaDumper.ignore_tables << /_plugin_/

namespace :noosfero do
  namespace :plugins do
    plugin_migration_dirs = Dir.glob(File.join(Rails.root, 'config', 'plugins', '*', 'db', 'migrate'))
    task :migrate do
      plugin_migration_dirs.each do |path|
        ActiveRecord::Migrator.migrate(path, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      end
    end

    task :save_enabled do
      ENV['ENABLED_PLUGINS'] = Dir.glob(File.join(Rails.root, 'config', 'plugins', '*')).map {|path| File.basename(path)}.reject {|a| a == "README"}.join(',')
    end

    task :temporary_config, :action, :needs => [:save_enabled] do |t, args|
      sh "./script/noosfero-plugins #{args.action}all"
    end

    task :restore_config do
      sh "./script/noosfero-plugins disableall"
      enabled_plugins = ENV['ENABLED_PLUGINS'].split(',')
      enabled_plugins.each do |plugin|
        sh "./script/noosfero-plugins enable #{plugin}"
      end
    end

    task :prepare_environment_disable do
      Rake::Task['noosfero:plugins:temporary_config'].invoke('disable')

      Rake::Task['environment'].enhance do
        Rake::Task['noosfero:plugins:restore_config'].invoke
      end
    end

    task :prepare_environment_enable do
      Rake::Task['noosfero:plugins:temporary_config'].invoke('enable')

      Rake::Task['environment'].enhance do
        Rake::Task['noosfero:plugins:restore_config'].invoke
      end
    end

    task :abort_if_pending_migrations do
      if defined? ActiveRecord
        plugin_migration_dirs.each do |path|
          pending_migrations = ActiveRecord::Migrator.new(:up, path).pending_migrations

          if pending_migrations.any?
            puts "You have #{pending_migrations.size} pending migrations:"
            pending_migrations.each do |pending_migration|
              puts '  %4d %s' % [pending_migration.version, pending_migration.name]
            end
            abort %{Run "rake db:migrate" to update your database then try again.}
          end
        end
      end
    end
  end
end

task 'db:migrate' => 'noosfero:plugins:migrate'
task 'db:abort_if_pending_migrations' => 'noosfero:plugins:abort_if_pending_migrations'
task 'environment' => 'noosfero:plugins:prepare_environment_disable'
