class CustomFormsPlugin::DateTimeField < CustomFormsPlugin::Field

  self.table_name = :custom_forms_plugin_fields

  validates_inclusion_of :show_as, :in => %w(datetime)

  after_initialize do
    self.show_as ||= 'datetime'
  end
end
