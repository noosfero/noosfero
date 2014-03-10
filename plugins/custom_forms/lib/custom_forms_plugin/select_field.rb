class CustomFormsPlugin::SelectField < CustomFormsPlugin::Field
  set_table_name :custom_forms_plugin_fields
  validates_inclusion_of :select_field_type, :in => %w(radio check_box select multiple_select)
  validates_length_of :alternatives, :minimum => 1, :message => 'can\'t be empty'
end
