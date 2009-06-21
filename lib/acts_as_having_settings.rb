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
      default = (!options[:default].nil?) ? options[:default].inspect : "val"
      data_type = options[:type] || :string

      names.each do |setting|
        class_eval <<-CODE
          def #{setting}
            val = send(self.class.settings_field)[:#{setting}]
            val.nil? ? (#{default}.is_a?(String) ? gettext(#{default}) : #{default}) : val
          end
          def #{setting}=(value)

            #UPGRADE Leandro: I add this line to save the serialize attribute
            send(self.class.settings_field.to_s + '_will_change!')

            send(self.class.settings_field)[:#{setting}] = self.class.acts_as_having_settings_type_cast(value, #{data_type.inspect})
          end
        CODE
      end
    end

    def acts_as_having_settings_type_cast(value, type)
      # FIXME creating a new instance at every call, will the garbage collector
      # be able to cope with it?
      ActiveRecord::ConnectionAdapters::Column.new(:dummy, nil, type.to_s).type_cast(value)
    end

  end

end

ActiveRecord::Base.send(:extend, ActsAsHavingSettings::ClassMethods)
