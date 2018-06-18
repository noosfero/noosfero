module ActiveRecordExtension

  module ClassMethods
    def reflect_on_association(name)
      reflection = super
      if reflection.nil? && self.superclass.respond_to?(:reflect_on_association)
        reflection = self.superclass.reflect_on_association(name)
      end
      reflection
    end

    def add_on_blank(attributes, custom_message = nil)
      for attr in [attributes].flatten
        value = @base.respond_to?(attr.to_s) ? @base.send(attr.to_s) : @base[attr.to_s]
        add(attr, :blank, :default => custom_message) if value.blank?
      end
    end
  end
end

ApplicationRecord.send :include, ActiveRecordExtension
