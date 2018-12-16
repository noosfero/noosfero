class AddPositionToFieldAndAlternatives < ActiveRecord::Migration[5.1]
  def self.up
    change_table :custom_forms_plugin_alternatives do |t|
      t.integer :position, :default => 0
    end

    update("UPDATE custom_forms_plugin_fields SET position=id")
    update("UPDATE custom_forms_plugin_alternatives SET position=id")

  end

  def self.down
    change_table :custom_forms_plugin_alternatives do |t|
      t.remove :position
    end
  end
end
