class Noosfero::Plugin::Manager

  attr_reader :environment
  attr_reader :context

  def initialize(environment, context)
    @environment = environment
    @context = context
    Environment.macros = {environment.id => {}} unless environment.nil?
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

  def dispatch_plugins(event, *args)
    map { |plugin| plugin.class if plugin.send(event, *args) }.compact.flatten
  end

  def dispatch_without_flatten(event, *args)
    map { |plugin| plugin.send(event, *args) }.compact
  end

  def dispatch_first(event, *args)
    value = nil
    map do |plugin| 
      value = plugin.send(event, *args) 
      break if value
    end
    value
  end

  alias :dispatch_scopes :dispatch_without_flatten

  def first(event, *args)
    result = nil
    each do |plugin|
      result = plugin.send(event, *args)
      break if result.present?
    end
    result
  end

  def first_plugin(event, *args)
    result = nil
    each do |plugin|
      if plugin.send(event, *args)
        result = plugin.class
        break
      end
    end
    result
  end

  def enabled_plugins
    @enabled_plugins ||= (Noosfero::Plugin.all & environment.enabled_plugins).map do |plugin|
      plugin.constantize.new(context)
    end
  end

  def [](name)
    klass = Noosfero::Plugin.klass(name)
    enabled_plugins.select do |plugin|
      plugin.kind_of?(klass)
    end.first
  end

end
