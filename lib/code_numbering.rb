module CodeNumbering
  module ClassMethods
    def code_numbering field, options = {}
      class_attribute :code_numbering_field
      class_attribute :code_numbering_options

      self.code_numbering_field = field
      self.code_numbering_options = options

      before_create :create_code_numbering

      include CodeNumbering::InstanceMethods
    end
  end

  module InstanceMethods

    def code
      self.attributes[self.code_numbering_field.to_s]
    end

    def code_scope
      scope = self.code_numbering_options[:scope]
      case scope
      when Symbol
        self.send scope
      when Proc
        instance_exec &scope
      else
        self.class
      end
    end

    def code_maximum
      self.code_scope.maximum(self.code_numbering_field) || 0
    end

    def create_code_numbering
      max = self.code_numbering_options[:start].to_i - 1 if self.code_numbering_options[:start]
      max = self.code_maximum
      self.send "#{self.code_numbering_field}=", max+1
    end

    def reset_scope_code_numbering
      max = self.code_numbering_options[:start].to_i - 1 if self.code_numbering_options[:start]
      max ||= 1

      self.code_scope.order(:created_at).each do |record|
        record.update_column self.code_numbering_field, max
        max += 1
      end
      self.reload
    end

  end
end

ActiveRecord::Base.extend CodeNumbering::ClassMethods
