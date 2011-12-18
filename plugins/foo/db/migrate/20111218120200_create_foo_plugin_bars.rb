class CreateFooPluginBars < ActiveRecord::Migration
  def self.up
    create_table :foo_plugin_bars do |t|
      t.string :name
    end
    add_column :profiles, :bar_id, :integer
  end
  def self.down
    drop_table :foo_plugin_bars
    remove_column :profile, :bar_id
  end
end
