class CustomFormsPlugin::SelectField < CustomFormsPlugin::Field
  set_table_name :custom_forms_plugin_fields

  validates_length_of :select_field_type, :minimum => 1, :allow_nil => false
  validates_inclusion_of :select_field_type, :in => %w(radio check_box select multiple_select)
end
