class Kalibro::Model

  def initialize(attributes={})
    attributes.each { |field, value| send("#{field}=", value) }
  end
 
  def to_hash
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

  protected

  def fields
    instance_variable_names.each.collect { |variable| variable.to_s.sub(/@/, '').to_sym }
  end

  def convert_to_hash(value)  
    return value if value.nil?
    return value.to_hash if value.is_a?(Kalibro::Model)
    value
  end

  def xml_class_name(entity)
    xml_name = entity.class.name
    xml_name["Kalibro::"] = ""
    xml_name[0..0] = xml_name[0..0].downcase
    xml_name + "Xml"
  end

end
