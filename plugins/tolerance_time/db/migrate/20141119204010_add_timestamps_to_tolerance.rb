class AddTimestampsToTolerance < ActiveRecord::Migration[5.1]
  def change
    add_timestamps :tolerance_time_plugin_tolerances
  end
end
