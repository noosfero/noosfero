class Kalibro::ModuleResult < Kalibro::Model

  attr_accessor :module, :date, :grade, :metric_result, :compound_metric_with_error
  
  def self.find_by_project_name_and_module_name_and_date(project_name, module_name, date)
    response = request(
    'ModuleResult',
    :get_module_result,
      {
        :project_name => project_name, 
        :module_name => module_name,
        :date => date_with_milliseconds(date)
      })[:module_result]
    new response
  end
  
  def self.all_by_project_name_and_module_name(project_name, module_name)
    response = request(
    'ModuleResult',
    :get_result_history,
      {
        :project_name => project_name, 
        :module_name => module_name,
      })[:module_result]
    to_objects_array(response)
  end
  
  def module=(value)
    @module = to_object(value, Kalibro::Module)
  end

  def date=(value)
    @date = value.is_a?(String) ? DateTime.parse(value) : value
  end

  def grade=(value)
    @grade = value.to_f
  end

  def metric_result=(value)
    @metric_result = to_objects_array(value, Kalibro::MetricResult)
  end
  
  private

  def self.date_with_milliseconds(date)
    milliseconds = "." + (date.sec_fraction * 60 * 60 * 24 * 1000).to_s
    date.to_s[0..18] + milliseconds + date.to_s[19..-1]
  end


end
