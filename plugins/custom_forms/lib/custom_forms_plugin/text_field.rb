class CustomFormsPlugin::TextField < CustomFormsPlugin::Field

  self.table_name = :custom_forms_plugin_fields

  validates_inclusion_of :show_as, :in => %w(text textarea)

  after_initialize do
    self.show_as ||= 'text'
  end
end
