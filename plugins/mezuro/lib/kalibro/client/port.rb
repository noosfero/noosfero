require 'savon'

Savon.configure do |config|
  config.log = HTTPI.log = (RAILS_ENV == 'development')
end

class Kalibro::Client::Port

  def initialize(endpoint)
    @client = Savon::Client.new("#{service_address}#{endpoint}Endpoint/?wsdl")
  end

  def service_address
    if @service_address.nil?
      service_file = "#{RAILS_ROOT}/plugins/mezuro/SERVICE"
      File.open(service_file).each_line{ | line | @service_address = line }
    end
    @service_address
  end

  def request(action, request_body = nil)
    response = @client.request(:kalibro, action) { soap.body = request_body }
    response.to_hash["#{action}_response".to_sym]
  end

end
