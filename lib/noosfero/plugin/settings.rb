class Noosfero::Plugin::Settings

  def initialize(base, plugin, attributes = nil)
    @base = base
    @plugin = plugin
    attributes ||= {}
    attributes.each do |k,v|
      self.send("#{k}=", v)
    end
  end

  def settings
    @base.settings["#{@plugin.public_name}_plugin".to_sym] ||= {}
  end

  def method_missing(method, *args, &block)
    if method.to_s =~ /^(.+)=$/
      set_setting($1, args.first)
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

  def set_setting(name, value)
    settings[name.to_sym] = value
  end

  def save!
    @base.save!
  end

end

