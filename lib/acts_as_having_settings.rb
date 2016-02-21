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
        ::Array.wrap(value)
      end
    end
    class Hash < Value
      def cast_value value
        h = ::Hash[value]
        h.symbolize_keys!
        h
      end
    end
  end
end

module ActsAsHavingSettings

  def self.type_cast value, type
    # do not cast nil
    return value if value.nil?
    type.send :cast_value, value
  end

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

    def settings_items *names

      options = names.extract_options!
      default = options[:default]
      type = options[:type]
      type = if type.present? then ActiveRecord::Type.const_get(type.to_s.camelize.to_sym).new else nil end

      names.each do |setting|
        # symbolize key
        setting = setting.to_sym

        define_method setting do
          h = send self.class.settings_field
          val = h[setting]
          # translate default value if it is used
          if not val.nil? then val elsif default.is_a? String then gettext default else default end
        end

        define_method "#{setting}=" do |value|
          h = send self.class.settings_field
          h[setting] = if type then ActsAsHavingSettings.type_cast value, type else value end
        end
      end
    end

  end

end

ApplicationRecord.extend ActsAsHavingSettings::ClassMethods

