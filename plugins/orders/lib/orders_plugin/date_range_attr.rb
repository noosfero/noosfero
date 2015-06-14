module OrdersPlugin

  # for use with Bootstrap daterangepicker
  module DateRangeAttr

    module ClassMethods

      def date_range_attr_for start_field, end_field
        "#{start_field}_#{end_field}_range"
      end

      def date_range_attr start_field, end_field, options = {}
        format = :momentjs_LLLL
        # dummy (default) means it is done with hidden fields in javascript
        options[:dummy] = true if options[:dummy].nil?

        range_attr = self.date_range_attr_for start_field, end_field
        attr_accessible range_attr

        define_method range_attr do
          return if options[:dummy]

          sep = I18n.t'orders_plugin.lib.date_helper.to'
          start_time = I18n.l(self.send(start_field) || Time.zone.now, format: format)
          end_time = I18n.l(self.send(end_field) || Time.zone.now+1.week, format: format)
          "#{start_time} #{sep} #{end_time}"
        end
        define_method "#{range_attr}=" do |value|
          return if options[:dummy]

          sep = I18n.t'orders_plugin.lib.date_helper.to'
          range = value.split sep
          start_time = Time.parse range.first, I18n.t("time.formats.#{format}")
          end_time = Time.parse range.last, I18n.t("time.formats.#{format}")
          self.send "#{start_field}=", start_time
          self.send "#{end_field}=", end_time
        end

        include InstanceMethods
      end

    end

    module InstanceMethods

      def date_range_attr_for start_field, end_field
        self.class.date_range_attr_for start_field, end_field
      end

    end

  end
end
