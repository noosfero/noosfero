require 'design'

class ActionController::Base

  # Declares that this controller uses design plugin to generate its layout.
  # See the plugin README for options that can be passed to this method.
  def self.design(config = {})

    raise ArgumentError.new("design argument must be a Hash") unless config.kind_of? Hash

    if (config.has_key?(:holder) && config.has_key?(:fixed)) || (!config.has_key?(:holder) && !config.has_key?(:fixed))
      raise ArgumentError.new("You must supply either <tt>:holder</tt> or <tt>:fixed</tt> to design.")
    end

    @design_plugin_config = config

    def self.design_plugin_config
      @design_plugin_config
    end

    include Design
    helper Design::Helper
  end

  # declares this controller as a design editor, including in it all the
  # functionalities to do that (besides those for using a design). Accepts the
  # same options as design.
  def self.design_editor(config = {})
    self.design(config)
    include Design::Editor
    helper Design::Editor::Helper
  end

end

class ActiveRecord::Base

  # declares an ActiveRecord class to be a design. The class is automatically
  # associated with a +has_many+ associationto Design::Block.
  #
  # The underlying database table *must* have a column named +design_data+ of
  # type +text+. +string+ should work too, but you may run into problems
  # related to length limit, so unless you have a very good reason not to, use
  # +text+ type.
  def self.acts_as_design
    has_many :boxes, :class_name => 'Design::Box', :as => :owner
    def blocks
      self.boxes.collect{|b| b.blocks}.flatten
    end
  end
end
