require 'active_record'
#require_dependency 'active_record/migration'

namespace :noosfero do
  namespace :plugins do

    plugin_migration_dirs = Dir.glob(Rails.root.join('{baseplugins,config/plugins}', '*', 'db', 'migrate'))

    task :load_config do
      dirs = Dir.glob("{baseplugins,config/plugins}/*/db/migrate")
      dirs.each do |dir|
        ActiveRecord::Migrator.migrations_paths << dir
      end
    end

    task :migrate do
      plugin_migration_dirs.each do |path|
        ActiveRecord::Migrator.migrate(path, ENV["VERSION"] ?
                                       ENV["VERSION"].to_i : nil)
      end
    end
  end
end

task 'db:migrate'     => 'noosfero:plugins:load_config'
task 'db:schema:load' => 'noosfero:plugins:load_config'
