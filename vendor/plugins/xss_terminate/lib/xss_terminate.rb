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
      # :on is util when before_filter dont work for model
      case options[:on]
        when 'create'
          before_create :sanitize_fields
        when 'validation'
          before_validation :sanitize_fields
        else
          before_save :sanitize_fields
      end

      sanitizer = case options[:with]
        when 'html5lib'
          HTML5libSanitize.new
        when 'white_list'
          RailsSanitize.white_list_sanitizer
        else
          RailsSanitize.full_sanitizer
      end

      write_inheritable_attribute(:xss_terminate_options, {
        :except => (options[:except] || []),
        :only => (options[:only] || options[:sanitize] || []),
        :sanitizer => sanitizer,

        :html5lib_sanitize => (options[:html5lib_sanitize] || [])
      })

      class_inheritable_reader :xss_terminate_options

      include XssTerminate::InstanceMethods
    end
  end

  module InstanceMethods

    def sanitize_fields

      columns = self.class.columns.select{ |i| i.type == :string || i.type == :text }.map{ |i| i.name }
      columns_serialized = self.class.serialized_attributes.keys

      if !xss_terminate_options[:only].empty?
        columns = columns.select{ |i| xss_terminate_options[:only].include?( i.to_sym ) }
      elsif !xss_terminate_options[:except].empty?
        columns.delete_if{ |i| xss_terminate_options[:except].include?( i.to_sym ) }
      end

      columns.each do |column|
        field = column.to_sym
        if columns_serialized.include?(column)
          next unless self[field]
          self[field].each_key { |key|
            key = key.to_sym
            self[field][key] = xss_terminate_options[:sanitizer].sanitize(self[field][key])
          }
        else
          self[field] = xss_terminate_options[:sanitizer].sanitize(self[field])
        end
      end

    end

  end

end
