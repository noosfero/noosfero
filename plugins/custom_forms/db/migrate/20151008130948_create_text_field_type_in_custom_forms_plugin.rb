class CreateTextFieldTypeInCustomFormsPlugin < ActiveRecord::Migration
  def up
    rename_column :custom_forms_plugin_fields, :select_field_type, :show_as
    change_column :custom_forms_plugin_fields, :show_as, :string, :null => true, :default => nil
    update("UPDATE custom_forms_plugin_fields SET show_as='text' WHERE type = 'CustomFormsPlugin::TextField'")
  end

  def down
    rename_column :custom_forms_plugin_fields, :show_as, :select_field_type
    change_column :custom_forms_plugin_fields, :select_field_type, :string, :null => false, :default => 'radio'
    update("UPDATE custom_forms_plugin_fields SET select_field_type='radio' WHERE type = 'CustomFormsPlugin::TextField'")
  end
end
