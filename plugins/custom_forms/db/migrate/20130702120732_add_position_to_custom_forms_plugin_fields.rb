class AddPositionToCustomFormsPluginFields < ActiveRecord::Migration[5.1]
  def self.up
    change_table :custom_forms_plugin_fields do |t|
      t.integer :position, :default => 0
    end
  end

  def self.down
    change_table :custom_forms_plugin_fields do |t|
      t.remove :position
    end
  end
end
