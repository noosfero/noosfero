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
          self[field][key] = sanitizer.sanitize(self[field][key])
        }
      else
        if self[field]
          self[field] = sanitizer.sanitize(self[field])
        else
          value = self.send("#{field}")
          return unless value
          value = sanitizer.sanitize(value)
          self.send("#{field}=", value)
        end
      end
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
      sanitizer = ActionView::Base.full_sanitizer
      columns, columns_serialized = sanitize_columns(:full)
      columns.each do |column|
        sanitize_field(sanitizer, column.to_sym, columns_serialized.include?(column))
      end
    end

    def sanitize_fields_with_white_list
      sanitizer = ActionView::Base.white_list_sanitizer
      columns, columns_serialized = sanitize_columns(:white_list)
      columns.each do |column|
        sanitize_field(sanitizer, column.to_sym, columns_serialized.include?(column))
      end
   end

    def sanitize_fields_with_html5lib
      sanitizer = HTML5libSanitize.new
      columns = sanitize_columns(:html5lib)
      columns.each do |column|
        sanitize_field(sanitizer, column.to_sym, columns_serialized.include?(column))
      end
    end

  end

end
