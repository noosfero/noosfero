class Kalibro::Project < Kalibro::Model
  attr_accessor :name, :license, :description, :repository, :configuration_name, :state, :error

  def self.all_names
    request(:get_project_names)[:project_name]
  end
  
  def self.find_by_name(project_name)
    attributes = request(:get_project, :project_name => project_name)[:project]
    new attributes
  end

  def save
    self.class.request(:save_project, {:project => to_hash})
  end

  def repository=(value)
    @repository = (value.kind_of?(Hash)) ? Kalibro::Repository.new(value) : value
  end
  
  private
  
  def self.client
    endpoint = "Project"
    service_address = YAML.load_file("#{RAILS_ROOT}/plugins/mezuro/service.yaml")
    Savon::Client.new("#{service_address}#{endpoint}Endpoint/?wsdl")
  end

  def self.request(action, request_body = nil)
    response = client.request(:kalibro, action) { soap.body = request_body }
    response.to_hash["#{action}_response".to_sym]
  end
  
end

