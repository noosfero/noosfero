class Noosfero::API::Entity < Grape::Entity

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
