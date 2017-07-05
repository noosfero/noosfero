class Noosfero::Plugin::CustomData

  def initialize(base, plugin, attributes = nil, type = nil)
    @base = base
    @plugin = plugin
    attributes ||= {}
    attributes.each do |k,v|
      self.send("#{k}=", v, type.try("[]", k))
    end
  end

  def data_field_name
    raise 'must be overridden by child class'
  end

  def get_custom_data(field_name)
    raise 'must be overridden by child class'
  end

  def set_custom_data(field_name, value, type)
    raise 'must be overridden by child class'
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /^(.+)=$/
      set_custom_data($1, args.first, args.second)
    elsif method.to_s =~ /^(.+)$/
      get_custom_data($1)
    end
  end

  def save!
    @base.save!
  end

  def get_custom_value(field_name)
    if @plugin.respond_to?("#{field_name}_default_#{data_field_name}")
      @plugin.send("#{field_name}_default_#{data_field_name}")
    else
      nil
    end
  end

end
