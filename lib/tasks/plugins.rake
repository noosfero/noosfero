ActiveRecord::SchemaDumper.ignore_tables << /_plugin_/

namespace :noosfero do
  namespace :plugins do
    plugin_migration_dirs = Dir.glob(File.join(Rails.root, 'config', 'plugins', '*', 'db', 'migrate'))
    task :migrate do
      plugin_migration_dirs.each do |path|
        ActiveRecord::Migrator.migrate(path, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
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
