require_dependency 'open_graph_plugin/stories'

# This is used when ActionTracker is not compartible with the way
module OpenGraphPlugin::AttachStories

  module ClassMethods

    def open_graph_attach_stories options={}
      if stories = Array(options[:only])
        callbacks = {}
        stories.each do |story|
          defs = OpenGraphPlugin::Stories::Definitions[story]
          Array(defs[:on]).each do |on|
            callbacks[on] ||= []
            callbacks[on] << story
          end
        end
      else
        klass = self.name
        callbacks = OpenGraphPlugin::Stories::ModelStories[klass.to_sym]
        return if callbacks.blank?
      end

      callbacks.each do |on, stories|
        # subclasses may override this, but the callback is called only once
        method = "open_graph_publish_after_#{on}"

        self.send "after_#{on}", method
        # buggy with rails 3.2
        #self.send "after_commit", method, on: on

        define_method method do
          OpenGraphPlugin::Stories.publish self, stories
        end
      end
    end

  end

  module InstanceMethods

  end

end
