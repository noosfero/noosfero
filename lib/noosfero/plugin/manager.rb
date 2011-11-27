class Noosfero::Plugin::Manager

  attr_reader :context

  def initialize(controller)
    @context = Noosfero::Plugin::Context.new(controller)
  end

  def map(event, *args)
    enabled_plugins.map { |plugin| plugin.send(event, *args) }.compact.flatten
  end

  def collect(&block)
    enabled_plugins.collect(&block)
  end

  def enabled_plugins
    @enabled_plugins ||= (Noosfero::Plugin.all & context.environment.enabled_plugins).map do |plugin|
      p = plugin.constantize.new
      p.context = context
      p
    end
  end

end
