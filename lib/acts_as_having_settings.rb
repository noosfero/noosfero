module ActsAsHavingSettings

  module ClassMethods
    def acts_as_having_settings(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      
      settings_field = options[:field] || 'settings'

      class_eval <<-CODE
        serialize :#{settings_field}, Hash
        def self.settings_field
          #{settings_field.inspect}
        end
        def #{settings_field}
          self[:#{settings_field}] ||= Hash.new
        end
      CODE
      settings_items(*args)
    end

    def settings_items(*names)

      options = names.last.is_a?(Hash) ? names.pop : {}
      default = options[:default] ? "|| #{options[:default].inspect}"  : ""

      names.each do |setting|
        class_eval <<-CODE
          def #{setting}
            send(self.class.settings_field)[:#{setting}] #{default}
          end
          def #{setting}=(value)
            send(self.class.settings_field)[:#{setting}] = value
          end
        CODE
      end
    end

  end

end

ActiveRecord::Base.send(:extend, ActsAsHavingSettings::ClassMethods)
