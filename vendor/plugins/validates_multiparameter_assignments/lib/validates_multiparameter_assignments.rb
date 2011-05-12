module ActiveRecord
  module Validations
    module ClassMethods
      def validates_multiparameter_assignments(options = {})
        configuration = if Rails::VERSION::STRING < "2.2.0"
          { :message => _("%{fn} is invalid.") }
        else
          { :message => I18n.translate('activerecord.errors.messages')[:invalid] }
        end.update(options)
        
        alias_method :assign_multiparameter_attributes_without_rescuing, :assign_multiparameter_attributes
        attr_accessor :assignment_error_attrs
        
        define_method(:assign_multiparameter_attributes) do |pairs|
          self.assignment_error_attrs = []
          begin
            assign_multiparameter_attributes_without_rescuing(pairs)
          rescue ActiveRecord::MultiparameterAssignmentErrors
            $!.errors.each do |error|
              self.assignment_error_attrs << error.attribute
            end
          end
        end
        private :assign_multiparameter_attributes
        
        validate do |record|
          record.assignment_error_attrs && record.assignment_error_attrs.each do |attr|
            record.errors.add(attr, configuration[:message])
          end
        end
      end
    end
  end
end
