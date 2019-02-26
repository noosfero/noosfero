class CreateToleranceTimePluginPublications < ActiveRecord::Migration[5.1]
  def self.up
    create_table :tolerance_time_plugin_publications do |t|
      t.references :target, :polymorphic => true, index: {:name => 'index_fnNcbSS1'}
      t.timestamps
    end
  end

  def self.down
    drop_table :tolerance_time_plugin_publications
  end
end
