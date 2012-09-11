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

  def dispatch_without_flatten(event, *args)
    map { |plugin| plugin.send(event, *args) }.compact
  end

  alias :dispatch_scopes :dispatch_without_flatten

  def enabled_plugins
    @enabled_plugins ||= (Noosfero::Plugin.all & environment.enabled_plugins).map do |plugin|
      p = plugin.constantize.new
      p.context = context
      p
    end
  end

  def [](name)
    klass = Noosfero::Plugin.klass(name)
    enabled_plugins.select do |plugin|
      plugin.kind_of?(klass)
    end.first
  end

end
