class CustomFormsPlugin::TextField < CustomFormsPlugin::Field
  set_table_name :custom_forms_plugin_fields

  attr_accessible :name
end
