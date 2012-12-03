class CustomFormsPlugin::SelectField < CustomFormsPlugin::Field
  set_table_name :custom_forms_plugin_fields
  validates_presence_of :choices
end
