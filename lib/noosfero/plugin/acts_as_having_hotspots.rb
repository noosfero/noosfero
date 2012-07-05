module ActsAsHavingHotspots
  module ClassMethods
    # Adding this feature to a class demands that it defines an instance method
    # 'environment' that returns the environment associated with the instance.
    def acts_as_having_hotspots
      send :include, InstanceMethods
    end

    module InstanceMethods
      # Dispatches +event+ to each enabled plugin and collect the results.
      #
      # Returns an Array containing the objects returned by the event method in
      # each plugin. This array is compacted (i.e. nils are removed) and flattened
      # (i.e. elements of arrays are added to the resulting array). For example, if
      # the enabled plugins return 1, 0, nil, and [1,2,3], then this method will
      # return [1,0,1,2,3]
      #
      def dispatch(event, *args)
        enabled_plugins.map { |plugin| plugin.send(event, *args) }.compact.flatten
      end

      # Dispatch without flatten since scopes are executed if you run flatten on them
      def dispatch_scopes(event, *args)
        enabled_plugins.map { |plugin| plugin.send(event, *args) }.compact
      end

      def enabled_plugins
        Thread.current[:enabled_plugins] ||= (Noosfero::Plugin.all & environment.enabled_plugins).map do |plugin_name|
          plugin = plugin_name.constantize.new
          plugin.context = context
          plugin
        end
      end

      if !method_defined?(:context)
        define_method(:context) do
          Noosfero::Plugin::Context.new
        end
      end
    end
  end
end

ActiveRecord::Base.send(:extend, ActsAsHavingHotspots::ClassMethods)
