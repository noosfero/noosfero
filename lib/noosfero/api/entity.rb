class Noosfero::API::Entity < Grape::Entity

  def initialize(object, options = {})
    object = nil if object.is_a? Exception
    super object, options
  end

  def self.represent(objects, options = {})
    if options[:has_exception]
      data = super objects, options.merge(is_inner_data: true)
      if objects.is_a? Exception
        data.merge ok: false, error: {
          type: objects.class.name,
          message: objects.message
        }
      else
        data = data.serializable_hash if data.is_a? Noosfero::API::Entity
        data.merge ok: true, error: { type: 'Success', message: '' }
      end
    else
      super objects, options
    end
  end

  def self.fields_condition(fields)
    lambda do |object, options|
      return true if options[:fields].blank?
      fields.map { |field| options[:fields].include?(field.to_s)}.grep(true).present?
    end
  end

  def self.expose(*args, &block)
    hash = args.last.is_a?(Hash) ? args.pop : {}
    hash.merge!({:if => fields_condition(args)}) if hash[:if].blank?
    args << hash
    super
  end

end
