module HMVC

  # controller_paths by context and controller
  mattr_accessor :paths_by_context
  self.paths_by_context = {}

  module ClassMethods

    def hmvc context, options = {}
      class_attribute :inherit_templates
      class_attribute :hmvc_inheritable
      class_attribute :hmvc_context
      class_attribute :hmvc_paths

      self.inherit_templates = true
      self.hmvc_inheritable = true
      self.hmvc_context = context
      self.hmvc_paths = (HMVC.paths_by_context[self.hmvc_context] ||= {})

      class_attribute :hmvc_orders_context
      self.hmvc_orders_context = options[:orders_context] || self.superclass.hmvc_orders_context rescue nil

      # initialize other context's controllers paths
      controllers = [self] + context.controllers.map{ |controller| controller.constantize }

      controllers.each do |klass|
        context_klass = klass
        while ((klass = klass.superclass).hmvc_inheritable rescue false)
          self.hmvc_paths[klass.controller_path] ||= context_klass.controller_path
        end
      end

      include InstanceMethods
      helper UrlHelpers
    end

    def hmvc_lookup_path controller_path
      self.hmvc_paths[controller_path] || controller_path
    end

  end

  module InstanceMethods

    protected

  end

  module UrlHelpers

    def url_for options = {}
      return super unless options.is_a? Hash

      controller_path = options[:controller]
      controller_path ||= self.controller_path
      controller_path = controller_path.to_s

      dest_controller = self.controller.class.hmvc_lookup_path controller_path
      options[:controller] = dest_controller

      super
    end

  end

end
