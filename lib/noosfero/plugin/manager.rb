class Noosfero::Plugin::Manager

  extend ActsAsHavingHotspots::ClassMethods
  acts_as_having_hotspots

  attr_reader :context

  delegate :environment, :to => :context
  delegate :each, :to => :enabled_plugins
  include Enumerable

  def initialize(controller)
    @context = Noosfero::Plugin::Context.new(controller)
    Thread.current[:enabled_plugins] = (Noosfero::Plugin.all & environment.enabled_plugins).map do |plugin_name|
      plugin = plugin_name.constantize.new
      plugin.context = context
      plugin
    end
  end

  def [](name)
    klass = Noosfero::Plugin.klass(name)
    enabled_plugins.select do |plugin|
      plugin.kind_of?(klass)
    end.first
  end

end
