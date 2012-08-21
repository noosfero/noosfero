class CreateToleranceTimePluginTolerances < ActiveRecord::Migration
  def self.up
    create_table :tolerance_time_plugin_tolerances do |t|
      t.references  :profile
      t.integer     :content_tolerance
      t.integer     :comment_tolerance
    end
  end

  def self.down
    drop_table :tolerance_time_plugin_tolerances
  end
end
