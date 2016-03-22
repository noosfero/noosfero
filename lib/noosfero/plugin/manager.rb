class Noosfero::Plugin::Manager

  attr_reader :environment
  attr_reader :context

  def initialize(environment, context)
    @environment = environment
    @context = context
  end

  delegate :each, :to => :enabled_plugins
  include Enumerable

  # Dispatches +event+ to each enabled plugin and collect the results.
  #
  # Returns an Array containing the objects returned by the event method in
  # each plugin. This array is compacted (i.e. nils are removed) and flattened
  # (i.e. elements of arrays are added to the resulting array). For example, if
  # the enabled plugins return 1, 0, nil, and [1,2,3], then this method will
  # return [1,0,1,2,3]
  #
  def dispatch(event, *args)
    dispatch_without_flatten(event, *args).flatten
  end

  def fetch_plugins(event, *args)
    map { |plugin| plugin.class if plugin.send(event, *args) }.compact.flatten
  end

  def dispatch_without_flatten(event, *args)
    map { |plugin| plugin.send(event, *args) }.compact
  end

  alias :dispatch_scopes :dispatch_without_flatten

  def dispatch_first(event, *args)
    default = Noosfero::Plugin.new.send(event, *args)
    result = default
    each do |plugin|
      result = plugin.send(event, *args)
      break if result != default
    end
    result
  end

  def fetch_first_plugin(event, *args)
    default = Noosfero::Plugin.new.send(event, *args)
    result = nil
    each do |plugin|
      if plugin.send(event, *args) != default
        result = plugin.class
        break
      end
    end
    result
  end

  def pipeline(event, *args)
    each do |plugin|
      result = Array(plugin.send event, *args)
      result = result.kind_of?(Array) ? result : [result]
      raise ArgumentError, "Pipeline broken by #{plugin.class.name} on #{event} with #{result.length} arguments instead of #{args.length}." if result.length != args.length
      args = result
    end
    args.length < 2 ? args.first : args
  end

  def filter(property, data)
    inject(data) {|data, plugin| data = plugin.send(property, data)}
  end

  def parse_macro(macro_name, macro, source = nil)
    macro_instance = enabled_macros[macro_name] || default_macro
    macro_instance.convert(macro, source)
  end

  def enabled_plugins
    environment_enabled_plugins = environment.present? ? environment.enabled_plugins : []
    @enabled_plugins ||= (Noosfero::Plugin.all & environment_enabled_plugins).map do |plugin|
      Noosfero::Plugin.load_plugin_identifier(plugin).new context
    end
  end

  def default_macro
    @default_macro ||= Noosfero::Plugin::Macro.new(context)
  end

  def enabled_macros
    @enabled_macros ||= dispatch(:macros).inject({}) do |memo, macro|
      memo.merge!(macro.identifier => macro.new(context))
    end
  end

  def [](class_name)
    enabled_plugins.select do |plugin|
      plugin.kind_of?(class_name.constantize)
    end.first
  end

end
