class Noosfero::Plugin::Manager

  attr_reader :context

  def initialize(controller)
    @context = Noosfero::Plugin::Context.new(controller)
  end

  def map(event)
    enabled_plugins.map { |plugin| plugin.send(event) }.compact.flatten
  end

  def enabled_plugins
    @enabled_plugins ||= (Noosfero::Plugin.all & context.environment.enabled_plugins).map do |plugin|
      p = eval(plugin).new
      p.context = context
      p
    end
  end

end
