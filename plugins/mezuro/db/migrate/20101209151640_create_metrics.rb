class CreateMetrics < ActiveRecord::Migration
  def self.up
    create_table :mezuro_plugin_metrics do |t|
      t.string  :name
      t.float   :value
      t.integer :metricable_id
      t.string  :metricable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :mezuro_plugin_metrics
  end
end
