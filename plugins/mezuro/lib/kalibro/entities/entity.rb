class Kalibro::Entities::Entity

  def self.from_hash(hash)
    entity = self.new
    hash.each { |field, value| entity.set(field, value) if is_valid?(field) }
    entity
  end

  def self.is_valid?(field)
    field.to_s[0] != '@' and field != :attributes!
  end

  def self.date_with_milliseconds(date)
    milliseconds = "." + (date.sec_fraction * 60 * 60 * 24 * 1000).to_s
    date.to_s[0..18] + milliseconds + date.to_s[19..-1]
  end

  def set(field, value)
    send("#{field}=", value) if not field.to_s.start_with? '@'
  end

  def to_entity_array(value, entity_class = nil)
    array = value.kind_of?(Array) ? value : [value]
    array.each.collect { |element| to_entity(element, entity_class) }
  end

  def to_entity(value, entity_class)
    value.kind_of?(Hash) ? entity_class.from_hash(value) : value
  end

  def to_hash
    hash = Hash.new
    fields.each do |field|
      field_value = self.get(field)
      hash[field] = convert_to_hash(field_value) if ! field_value.nil?
      if need_xml_type?(field_value)
        hash = {:attributes! => {}}.merge(hash)
        hash[:attributes!][field.to_sym] = {
          'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:type' => 'kalibro:' + xml_class_name(field_value)  }
      end
    end
    hash
  end

  def ==(other)
    begin
      fields.each.inject(true) { |equal, field| equal && (self.get(field) == other.get(field)) }
    rescue NoMethodError
      false
    end
  end

  protected

  def fields
    instance_variable_names.each.collect { |variable| variable.to_s.sub(/@/, '').to_sym }
  end

  def get(field)
    send("#{field}")
  end
  
  def convert_to_hash(value)
    return value.collect { |element| convert_to_hash(element) } if value.is_a?(Array)
    return value.to_hash if value.is_a?(Kalibro::Entities::Entity)
    return self.class.date_with_milliseconds(value) if value.is_a?(DateTime)
    return 'INF' if value.is_a?(Float) and value.infinite? == 1
    return '-INF' if value.is_a?(Float) and value.infinite? == -1
    value
  end

  def need_xml_type?(value)
    value.is_a?(Kalibro::Entities::Entity) and value.class.superclass != Kalibro::Entities::Entity
  end

  def xml_class_name(entity)
    xml_name = entity.class.name
    xml_name["Kalibro::Entities::"] = ""
    xml_name[0..0] = xml_name[0..0].downcase
    xml_name + "Xml"
  end
  
end
