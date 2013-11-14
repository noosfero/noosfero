class Noosfero::FieldsDecorator
  attr_accessor :object, :context

  def initialize(object, context = nil)
    @object = object
    @context = context
  end

  def method_missing(m, *args)
    object.send(m, *args)
  end

  def fields(field_names = {})
    field_names.inject({}) { |result, field| result.merge!(field => self.send(field))}
  end
end
