class Kalibro::Model

  attr_accessor :errors

  def initialize(attributes={})
    attributes.each { |field, value| send("#{field}=", value) if self.class.is_valid?(field) }
    @errors = []
  end

  def to_hash(options={})
    hash = Hash.new
    excepts = !options[:except].nil? ? options[:except] : []
    excepts << :errors
    fields.each do |field|
      if(!excepts.include?(field))
        field_value = send(field)
        hash[field] = convert_to_hash(field_value) if ! field_value.nil?
        if field_value.is_a?(Kalibro::Model)
          hash = {:attributes! => {}}.merge(hash)
          hash[:attributes!][field.to_sym] = {
            'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
            'xsi:type' => 'kalibro:' + xml_class_name(field_value)  }
        end
      end
    end
    hash
  end

  def self.request(endpoint, action, request_body = nil)
    response = client(endpoint).request(:kalibro, action) { soap.body = request_body }
    response.to_hash["#{action}_response".to_sym] # response is a Savon::SOAP::Response, and to_hash is a Savon::SOAP::Response method
  end

  def self.to_objects_array value
    array = value.kind_of?(Array) ? value : [value]
    array.each.collect { |element| to_object(element) }
  end

  def self.to_object value
    value.kind_of?(Hash) ? new(value) : value
  end 
  
  def self.create(attributes={})
    new_model = new attributes
    new_model.save
    new_model
  end

  def save
    begin
      self.class.request(save_endpoint, save_action, save_params)
	    true
	  rescue Exception => exception
	    add_error exception
	    false
	  end
  end

  def destroy
    begin
      self.class.request(destroy_endpoint, destroy_action, destroy_params)
    rescue Exception => exception
	    add_error exception
    end
  end

  protected

  def fields
    instance_variable_names.each.collect { |variable| variable.to_s.sub(/@/, '').to_sym }
  end

  def convert_to_hash(value)
    return value if value.nil?
    return value.collect { |element| convert_to_hash(element) } if value.is_a?(Array)
    return value.to_hash if value.is_a?(Kalibro::Model)
    return self.class.date_with_milliseconds(value) if value.is_a?(DateTime)    
    return 'INF' if value.is_a?(Float) and value.infinite? == 1
    return '-INF' if value.is_a?(Float) and value.infinite? == -1
    value
  end

  def xml_class_name(object)
    xml_name = object.class.name
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
  
  def self.date_with_milliseconds(date)
    milliseconds = "." + (date.sec_fraction * 60 * 60 * 24 * 1000).to_s
    date.to_s[0..18] + milliseconds + date.to_s[19..-1]
  end
  
  def class_name
    self.class.name.gsub(/Kalibro::/,"")
  end
  
  def save_endpoint
    class_name
  end
  
  def save_action
    "save_#{class_name.underscore}".to_sym
  end
  
  def save_params
    {class_name.underscore.to_sym => self.to_hash}
  end
  
  def destroy_endpoint
    class_name
  end
  
  def destroy_action
    "remove_#{class_name.underscore}".to_sym
  end
  
  def destroy_params
    {"#{class_name.underscore}_name".to_sym => self.name}
  end

  def add_error(exception)
    @errors << exception
  end

end

