class AddTimestampsToTolerance < ActiveRecord::Migration
  def change
    add_timestamps :tolerance_time_plugin_tolerances
  end
end
