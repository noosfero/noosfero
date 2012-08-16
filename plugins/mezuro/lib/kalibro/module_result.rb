class Kalibro::ModuleResult < Kalibro::Model

  attr_accessor :module, :date, :grade, :metric_result, :compound_metric_with_error
  
  def self.find_by_project_name_and_module_name_and_date(project_name, module_name, date)
    new request(
    'ModuleResult',
    :get_module_result,
      {
        :project_name => project_name, 
        :module_name => module_name,
        :date => date_with_milliseconds(date)
      })[:module_result]
  end
  
  def self.all_by_project_name_and_module_name(project_name, module_name)
    response = request(
    'ModuleResult',
    :get_result_history,
      {
        :project_name => project_name, 
        :module_name => module_name
      })[:module_result]
    Kalibro::ModuleResult.to_objects_array(response)
  end
  
  def module=(value)
    @module = Kalibro::Module.to_object value
  end

  def date=(value)
    @date = value.is_a?(String) ? DateTime.parse(value) : value
  end

  def grade=(value)
    @grade = value.to_f
  end

  def metric_result=(value)
    @metric_result = Kalibro::MetricResult.to_objects_array value
  end
  
  def metric_results
    @metric_result
  end
  
  def metric_results=(metric_results)
    @metric_result = metric_results
  end

  def compound_metric_with_error=(value)
    @compound_metric_with_error = Kalibro::CompoundMetricWithError.to_objects_array value
  end

  def compound_metrics_with_error
    @compound_metric_with_error
  end

  def compound_metrics_with_error=(compound_metrics_with_error)
    @compound_metric_with_error = compound_metrics_with_error
  end

end
