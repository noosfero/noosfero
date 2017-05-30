class Noosfero::Plugin::Settings

  def initialize(base, plugin, attributes = nil, type = nil)
    @base = base
    @plugin = plugin
    attributes ||= {}
    attributes.each do |k,v|
      self.send("#{k}=", v, type.try("[]", k))
    end
  end

  def settings
    settings_field = @base.class.settings_field
    @base.send(settings_field)["#{@plugin.public_name}_plugin".to_sym] ||= {}
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /^(.+)=$/
      set_setting($1, args.first, args.second)
    elsif method.to_s =~ /^(.+)$/
      get_setting($1)
    end
  end

  def get_setting(name)
    if settings[name.to_sym].nil?
      if @plugin.respond_to?("#{name}_default_setting")
        @plugin.send("#{name}_default_setting")
      else
        nil
      end
    else
      settings[name.to_sym]
    end
  end

  def set_setting(name, value, type=nil)
    if type
      value = Noosfero::Plugin::Settings::ActsAsHavingSettings.type_cast(value, ActiveRecord::Type.const_get(type.to_s.camelize.to_sym).new)
    end
    settings[name.to_sym] = value
  end

  def save!
    @base.save!
  end

end
