require 'noosfero'
class Noosfero::Plugin

  attr_accessor :context

  class << self

    def init_system
      Dir.glob(File.join(Rails.root, 'config', 'plugins', '*')).select do |entry|
        File.directory?(entry)
      end.each do |dir|
        Rails.configuration.controller_paths << File.join(dir, 'controllers')
        Dependencies.load_paths << File.join(dir, 'controllers')
        [ Dependencies.load_paths, $:].each do |path|
          path << File.join(dir, 'models')
          path << File.join(dir, 'lib')
        end

        plugin_name = File.basename(dir).camelize + 'Plugin'
        plugin_name.constantize # load the plugin
      end
    end

    def all
      @all ||= []
    end

    def inherited(subclass)
      all << subclass.to_s unless all.include?(subclass.to_s)
    end

    # Here the developer should specify the meta-informations that the plugin can
    # inform.
    def plugin_name
      self.to_s.underscore.humanize
    end

    def plugin_description
      _("No description informed.")
    end

  end

  def expanded_template(original_path, file_path, locals = {})
    while(File.basename(File.dirname(original_path)) != 'plugins')
      original_path = File.dirname(original_path)
    end

    ERB.new(File.read("#{original_path}/#{file_path}")).result(binding)
  end

  # Here the developer should specify the events to which the plugins can
  # register to. Must be explicitly defined its returning
  # variables.

  # -> Adds buttons to the control panel
  # returns = { :title => title, :icon => icon, :url => url }
  #   title = name that will be displayed.
  #   icon  = css class name (for customized icons include them in a css file).
  #   url   = url or route to which the button will redirect.
  def control_panel_buttons
    nil
  end

  # -> Adds tabs to the profile
  # returns   = { :title => title, :id => id, :content => content, :start => start }
  #   title   = name that will be displayed.
  #   id      = div id.
  #   content = content of the tab (use expanded_template method to import content from another file).
  #   start   = boolean that specifies if the tab must come before noosfero tabs (optional).
  def profile_tabs
    nil
  end

end
