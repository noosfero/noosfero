class Kalibro::ModuleResult < Kalibro::Model

  attr_accessor :module, :date, :grade, :metric_result, :compound_metric_with_error
  
  def self.find_module_result(project_name, module_name, date)
    result = module_result.request(
    :get_module_result,
      {
        :project_name => project_name, 
        :module_name => module_name,
        :date => date_with_milliseconds(date)
      })[:module_result]
    new result
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
  
  def self.module_result
    endpoint = "ModuleResult"
    service_address = YAML.load_file("#{RAILS_ROOT}/plugins/mezuro/service.yaml")
    Savon::Client.new("#{service_address}#{endpoint}Endpoint/?wsdl")
  end
  
  def self.request(action, request_body = nil)
    response = module_result.request(:kalibro, action) { soap.body = request_body }
    response.to_hash["#{action}_response".to_sym]
  end
  
  def self.date_with_milliseconds(date)
    milliseconds = "." + (date.sec_fraction * 60 * 60 * 24 * 1000).to_s
    date.to_s[0..18] + milliseconds + date.to_s[19..-1]
  end


end
