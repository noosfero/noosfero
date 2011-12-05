class Kalibro::Entities::Entity

  def self.from_hash(hash)
    entity = self.new
    hash.each { |field, value| entity.set(field, value) }
    entity
  end

  def set(field, value)
    send("#{field}=", value)
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
    end
    hash
  end

  def convert_to_hash(value)
    return value.collect { |element| convert_to_hash(element) } if value.kind_of?(Array)
    return value.to_hash if value.kind_of?(Kalibro::Entities::Entity)
    value
  end

  def ==(other)
    begin
      fields.each.inject(true) { |equal, field| equal && (self.get(field) == other.get(field)) }
    rescue NoMethodError
      false
    end
  end

  def fields
    instance_variable_names.each.collect { |variable| variable.to_s.sub(/@/, '').to_sym }
  end

  def get(field)
    send("#{field}")
  end
  
end