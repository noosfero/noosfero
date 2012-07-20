class Kalibro::Model

  def initialize(attributes={})
    attributes.each { |field, value| send("#{field}=", value) if self.class.is_valid?(field) }
  end
 
  def to_hash # Convert an object into a hash
    hash = Hash.new
    fields.each do |field|
      field_value = send(field)
      hash[field] = convert_to_hash(field_value)
      if field_value.is_a?(Kalibro::Model)
        hash = {:attributes! => {}}.merge(hash)
        hash[:attributes!][field.to_sym] = {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:' + xml_class_name(field_value)  }
      end
    end
    hash
  end

  def self.request(endpoint, action, request_body = nil)
    response = client(endpoint).request(:kalibro, action) { soap.body = request_body }
    response.to_hash["#{action}_response".to_sym] # response is a Savon::SOAP::Response, and to_hash is a Savon::SOAP::Response method
  end
  protected

  def fields
    instance_variable_names.each.collect { |variable| variable.to_s.sub(/@/, '').to_sym }
  end

  def convert_to_hash(value)  
    return value if value.nil?
    return value.collect { |element| convert_to_hash(element) } if value.is_a?(Array)
    return value.to_hash if value.is_a?(Kalibro::Model)
    return 'INF' if value.is_a?(Float) and value.infinite? == 1
    return '-INF' if value.is_a?(Float) and value.infinite? == -1
    value
  end

  def xml_class_name(entity)
    xml_name = entity.class.name
    xml_name["Kalibro::"] = ""
    xml_name[0..0] = xml_name[0..0].downcase
    xml_name + "Xml"
  end

  def self.client(endpoint)
    service_address = YAML.load_file("#{RAILS_ROOT}/plugins/mezuro/service.yaml")
    Savon::Client.new("#{service_address}#{endpoint}Endpoint/?wsdl")
  end


  def self.is_valid?(field)
    field.to_s[0] != '@' and field != :attributes! and (field.to_s =~ /xsi/).nil?
  end

  def to_objects_array(value, model_class = nil)
    array = value.kind_of?(Array) ? value : [value]
    array.each.collect { |element| to_object(element, model_class) }
  end

  def to_object(value, model_class)
    value.kind_of?(Hash) ? model_class.new(value) : value
  end 

end
