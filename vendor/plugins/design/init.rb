require 'design'

class ActionController::Base

  # Declares that this controller uses design plugin to generate its layout.
  # See the plugin README for options that can be passed to this method.
  def self.design(config = {})
    if (config.has_key?(:holder) && config.has_key?(:fixed)) || (!config.has_key?(:holder) && !config.has_key?(:fixed))
      raise ArgumentError.new("You must supply either <tt>:holder</tt> or <tt>:fixed</tt> to design.")
    end

    @design_plugin_config = config

    include Design
  end

  # declares this controller as a design editor, including in it all the
  # functionalities to do that (besides those for using a design). Accepts the
  # same options as design.
  def self.design_editor(config = {})
    self.design(config)
    include Design::Editor
  end

end
