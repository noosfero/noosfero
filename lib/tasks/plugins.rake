require 'active_record'
#require_dependency 'active_record/migration'

namespace :noosfero do
  namespace :plugins do

    plugin_migration_dirs = Dir.glob(Rails.root.join('{baseplugins,config/plugins}', '*', 'db', 'migrate'))

    task :migrate do
      plugin_migration_dirs.each do |path|
        ActiveRecord::Migrator.migrate(path, ENV["VERSION"] ?
                                       ENV["VERSION"].to_i : nil)
      end
    end
  end
end

