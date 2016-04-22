module Customizable

  def self.included(base)
    base.attr_accessible :custom_values
    base.extend ClassMethods
  end

  module ClassMethods
    def acts_as_customizable(options = {})
      attr_accessor :custom_values
      has_many :custom_field_values, :dependent => :delete_all, :as => :customized
      send :include, Customizable::InstanceMethods
      after_save :save_custom_values
      validate :valid_custom_values?
    end

    def active_custom_fields environment
      environment.custom_fields.select{|cf| customized_ancestors_list.include?(cf.customized_type) && cf.active}
    end

    def required_custom_fields environment
      environment.custom_fields.select{|cf| customized_ancestors_list.include?(cf.customized_type) && cf.required}
    end

    def signup_custom_fields environment
      environment.custom_fields.select{|cf| customized_ancestors_list.include?(cf.customized_type) && cf.signup}
    end

    def custom_fields environment
      environment.custom_fields.select{|cf| customized_ancestors_list.include?(cf.customized_type)}
    end

    def customized_ancestors_list
      current=self
      result=[]
      while current.instance_methods.include? :custom_value do
        result << current.name
        current=current.superclass
      end
      result
    end

  end

  module InstanceMethods

    def valid_custom_values?
      is_valid = true
      parse_custom_values.each do |cv|
        unless cv.valid?
          name = cv.custom_field.name
          errors.add(name, cv.errors.messages[name.to_sym].first)
          is_valid = false
        end
      end
      is_valid
    end

    def customized_class
      current=self.class
      while current.instance_methods.include? :custom_fields do
        result=current
        current=current.superclass
      end
      result.name
    end

    def is_public(field_name)
      cv = self.custom_field_values.detect{|cv| cv.custom_field.name==field_name}
      cv.nil? ? false : cv.public
    end

    def public_values
      self.custom_field_values.select{|cv| cv.public}
    end

    def custom_value(field_name)
      cv = self.custom_field_values.detect{|cv| cv.custom_field.name==field_name}
      cv.nil? ? default_value_for(field_name) : cv.value
    end

    def default_value_for(field_name)
      field=self.class.custom_fields(environment).detect {|c| c.name == field_name}
      field.nil? ? nil : field.default_value
    end

    def parse_custom_values
      return_list = []
      return return_list if custom_values.blank?
      custom_values.each_pair do |key, value|
        custom_field = environment.custom_fields.detect{|cf|cf.name==key}
        next if custom_field.blank?
        custom_field_value = self.custom_field_values(true).detect{|cv| cv.custom_field.name==key}

        if custom_field_value.nil?
          custom_field_value = CustomFieldValue.new
          custom_field_value.custom_field = custom_field
          custom_field_value.customized = self
        end

        if value.is_a?(Hash)
          custom_field_value.value = value['value'].to_s
          if value.has_key?('public')
            is_public = value['public']=="true" || value['public']==true
            custom_field_value.public = is_public
          else
            custom_field_value.public = false
          end
        else
          custom_field_value.value = value.to_s
          custom_field_value.public = false
        end
        return_list << custom_field_value
      end
      return_list
    end

    def save_custom_values
      parse_custom_values.each(&:save)
    end

  end
end

ApplicationRecord.send :include, Customizable
