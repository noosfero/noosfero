class ClearDefaultThemeFromProfiles < ActiveRecord::Migration
  def self.up
    execute("update profiles set theme = null where theme = 'default'")
  end

  def self.down
    say "WARNING: cannot undo this migration"
  end
end
