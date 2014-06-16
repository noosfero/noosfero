require 'upload_sanitizer'

module ActiveRecordExtension

  extend ActiveSupport::Concern

  module ClassMethods
    def reflect_on_association(name)
      reflection = super
      if reflection.nil? && self.superclass.respond_to?(:reflect_on_association)
        reflection = self.superclass.reflect_on_association(name)
      end
      reflection
    end
  end
end
ActiveRecord::Base.send(:include, ActiveRecordExtension)
