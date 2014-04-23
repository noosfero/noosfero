require 'active_record'
require_dependency 'active_record/migration'

class ActiveRecord::Migrator
  alias_method :orig_initialize, :initialize
  def initialize *args
    orig_initialize *args
    @migrations_path = "{db/migrate,config/plugins/*/db/migrate}"
  end
end

namespace :noosfero do
  namespace :plugins do
    plugin_migration_dirs = Dir.glob(File.join(Rails.root, 'config',
                                               'plugins', '*', 'db', 'migrate'))
    task :migrate do
      plugin_migration_dirs.each do |path|
        ActiveRecord::Migrator.migrate(path, ENV["VERSION"] ?
                                       ENV["VERSION"].to_i : nil)
      end
    end
  end
end
