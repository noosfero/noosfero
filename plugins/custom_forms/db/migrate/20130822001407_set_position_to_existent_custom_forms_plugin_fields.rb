class SetPositionToExistentCustomFormsPluginFields < ActiveRecord::Migration
  def self.up
    update("UPDATE custom_forms_plugin_fields SET position = 0 WHERE position IS NULL")
  end

  def self.down
    say("Nothing to undo (cannot recover the data)")
  end
end
