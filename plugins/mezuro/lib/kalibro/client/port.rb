require 'savon'

class Kalibro::Client::Port

  @@service_address = 'http://localhost:8080/KalibroService/'

  def self.service_address
    @@service_address
  end

  def self.service_address=(service_address)
    @@service_address = service_address
  end

  def initialize(endpoint)
    @client = Savon::Client.new("#{@@service_address}#{endpoint}Endpoint/?wsdl")
  end

  def request(action, request_body = nil)
    response = @client.request(:kalibro, action) { soap.body = request_body }
    response.to_hash["#{action}_response".to_sym]
  end

end
