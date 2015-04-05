# declare missing types
module ActiveRecord
  module Type
    class Symbol < Value
      def cast_value value
        value.to_sym
      end
    end
    class Array < Value
      def cast_value value
        Array(value)
      end
    end
    class Hash < Value
      def cast_value value
        Hash[value]
      end
    end
  end
end

module ActsAsHavingSettings

  module ClassMethods

    def acts_as_having_settings(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      field = (options[:field] || :settings).to_sym

      serialize field, Hash
      class_attribute :settings_field
      self.settings_field = field

      class_eval do
        def settings_field
          self[self.class.settings_field] ||= Hash.new
        end

        def setting_changed? setting_field
          setting_field = setting_field.to_sym
          changed_settings = self.changes[self.class.settings_field]
          return false if changed_settings.nil?

          old_setting_value = changed_settings.first.nil? ? nil : changed_settings.first[setting_field]
          new_setting_value = changed_settings.last[setting_field]
          old_setting_value != new_setting_value
        end
      end

      settings_items *args
    end

    def settings_items(*names)

      options = names.last.is_a?(Hash) ? names.pop : {}
      default = if !options[:default].nil? then options[:default] else nil end
      data_type = options[:type]
      data_type = if data_type.present? then data_type.to_s.camelize.to_sym else :String end
      data_type = ActiveRecord::Type.const_get(data_type).new

      names.each do |setting|
        # symbolize key
        setting = setting.to_sym

        define_method setting do
          h = send self.class.settings_field
          val = h[setting]
          if val.nil? then (if default.is_a? String then gettext default else default end) else val end
        end
        define_method "#{setting}=" do |value|
          h = send self.class.settings_field
          h[setting] = self.class.acts_as_having_settings_type_cast value, data_type
        end
      end
    end

    def acts_as_having_settings_type_cast value, type
      type.send :cast_value, value
    end

  end

end

ActiveRecord::Base.send(:extend, ActsAsHavingSettings::ClassMethods)
