class Kalibro::ModuleResult < Kalibro::Model

  attr_accessor :module, :date, :grade, :metric_result, :compound_metric_with_error
  
  def self.find_by_project_name_and_module_name_and_date(project_name, module_name, date)
    response = request(
    :get_module_result,
      {
        :project_name => project_name, 
        :module_name => module_name,
        :date => date_with_milliseconds(date)
      })[:module_result]
    new response
  end
  
  def self.all_module_results(project_name, module_name)
    response = request(
    :get_result_history,
      {
        :project_name => project_name, 
        :module_name => module_name,
      })[:module_result]
    to_entity_array(response)
  end
  
  #FIXME change Kalibro::Entities::Module
  def module=(value)
    @module = value.kind_of?(Hash) ? Kalibro::Entities::Module.from_hash(value) : value
  end

  def date=(value)
    @date = value.is_a?(String) ? DateTime.parse(value) : value
  end

  def grade=(value)
    @grade = value.to_f
  end

  #FIXME change Kalibro::Entities::MetricResult
  def metric_result=(value)
    array = value.kind_of?(Array) ? value : [value]
    @metric_result = array.each.collect { |element| element.kind_of?(Hash) ? Kalibro::Entities::MetricResult.from_hash(element) : element }
  end
  
  private
  
  def self.to_entity_array(value)
    array = value.kind_of?(Array) ? value : [value]
    array.each.collect { |element| to_entity(element) }
  end
  
  def self.to_entity(value)
    value.kind_of?(Hash) ? new(value) : value
  end
  
  def self.client
    endpoint = 'ModuleResult'
    service_address = YAML.load_file("#{RAILS_ROOT}/plugins/mezuro/service.yaml")
    Savon::Client.new("#{service_address}#{endpoint}Endpoint/?wsdl")
  end
  
  def self.request(action, request_body = nil)
    response = client.request(:kalibro, action) { soap.body = request_body }
    response.to_hash["#{action}_response".to_sym]
  end
  
  def self.date_with_milliseconds(date)
    milliseconds = "." + (date.sec_fraction * 60 * 60 * 24 * 1000).to_s
    date.to_s[0..18] + milliseconds + date.to_s[19..-1]
  end


end
