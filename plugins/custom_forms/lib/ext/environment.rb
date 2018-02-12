require_dependency 'environment'

class Environment

  DEFAULT_CSV_MAX_SIZE = 100.megabytes

  def submissions_csv_max_size
    self.custom_forms_plugin_metadata['max_csv_size'] || DEFAULT_CSV_MAX_SIZE
  end

  def custom_forms_plugin_metadata
    self.metadata['custom_forms_plugin'] ||= {}
  end

end
