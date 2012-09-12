class CreateToleranceTimePluginPublications < ActiveRecord::Migration
  def self.up
    create_table :tolerance_time_plugin_publications do |t|
      t.references :target, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :tolerance_time_plugin_publications
  end
end
