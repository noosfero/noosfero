module XssTerminate

  def self.sanitize_by_default=(value)
    @@sanitize_by_default = value
  end

  def self.included(base)
    base.extend(ClassMethods)
    # sets up default of stripping tags for all fields
    # FIXME read value from environment.rb
    @@sanitize_by_default = false
    base.send(:xss_terminate) if @@sanitize_by_default
  end

  module ClassMethods

    def xss_terminate(options = {})
      options[:with] ||= 'full'
      filter_with = 'sanitize_fields_with_' + options[:with]
      # :on is util when before_filter dont work for model
      case options[:on]
        when 'create'
          before_create filter_with
        when 'validation'
          before_validation filter_with
        else
          before_save filter_with
      end
      class_attribute "xss_terminate_#{options[:with]}_options".to_sym
      self.send("xss_terminate_#{options[:with]}_options=".to_sym, {
        :except => (options[:except] || []),
        :only => (options[:only] || options[:sanitize] || [])
      })
      include XssTerminate::InstanceMethods
    end

  end

  module InstanceMethods

    def sanitize_field(sanitizer, field, serialized = false)
      field = field.to_sym
      if serialized
        puts field
        self[field].each_key { |key|
          key = key.to_sym
          self[field][key] = sanitizer.sanitize(self[field][key], encode_special_chars: false, scrubber: permit_scrubber )
        }
      else
        if self[field]
          self[field] = sanitizer.sanitize(self[field], encode_special_chars: false, scrubber: permit_scrubber )
        else
          value = self.send("#{field}")
          return unless value
          value = sanitizer.sanitize(value, encode_special_chars: false, scrubber: permit_scrubber)
          self.send("#{field}=", value)
        end
      end
    end

    def  permit_scrubber
        scrubber = Rails::Html::PermitScrubber.new
        scrubber.tags = Rails.application.config.action_view.sanitized_allowed_tags
        scrubber.attributes = Rails.application.config.action_view.sanitized_allowed_attributes
        scrubber
    end

    def sanitize_columns(with = :full)
      columns_serialized = self.class.serialized_attributes.keys
      only = eval "xss_terminate_#{with}_options[:only]"
      except = eval "xss_terminate_#{with}_options[:except]"
      unless except.empty?
        only.delete_if{ |i| except.include?( i.to_sym ) }
      end
      return only, columns_serialized
    end

    def sanitize_fields_with_full
      sanitize_fields_with(Rails::Html::FullSanitizer.new,:full)
    end

    def sanitize_fields_with_white_list
      sanitize_fields_with(Rails::Html::WhiteListSanitizer.new,:white_list)
    end

    def sanitize_fields_with_html5lib
      sanitize_fields_with(HTML5libSanitize.new,:html5lib)
    end

    def sanitize_fields_with sanitizer, type
      columns, columns_serialized = sanitize_columns(type)
      columns.each {|column| sanitize_field(sanitizer, column.to_sym, columns_serialized.include?(column))}
    end

  end

end
