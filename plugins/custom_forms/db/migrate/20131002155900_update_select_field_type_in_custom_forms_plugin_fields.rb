class UpdateSelectFieldTypeInCustomFormsPluginFields < ActiveRecord::Migration
  def self.up
    change_column :custom_forms_plugin_fields, :select_field_type, :string, :null => false, :default => 'radio'
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
