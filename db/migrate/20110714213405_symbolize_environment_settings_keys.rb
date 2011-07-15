class SymbolizeEnvironmentSettingsKeys < ActiveRecord::Migration
  def self.up
    select_all("select id from environments").each do |environment|
      env = Environment.find(environment['id'])
      env.settings.symbolize_keys!
      env.save
    end
  end

  def self.down
    say "WARNING: cannot undo this migration"
  end
end
