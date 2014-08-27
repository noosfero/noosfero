class RemoveEnvironmentStatisticsBlock < ActiveRecord::Migration
  def self.up
    update("UPDATE blocks SET type = 'StatisticsBlock' WHERE type = 'EnvironmentStatisticsBlock'")
  end

  def self.down
    say("Nothing to undo (cannot recover the data)")
  end
end
