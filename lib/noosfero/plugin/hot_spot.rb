# This module must be included by classes that contain Noosfero plugin
# hotspots.
#
# Classes that include this module *must* provide a method called
# <tt>environment</tt> which returns an intance of Environment. This
# Environment will be used to determine which plugins are enabled and therefore
# which plugins should be instantiated.
module Noosfero::Plugin::HotSpot
  CALLBACK_HOTSPOTS =[:after_save, :after_destroy, :before_save, :before_destroy, :after_create, :before_create]

  # Returns an instance of Noosfero::Plugin::Manager.
  #
  # This which is intantiated on the first call and just returned in subsequent
  # calls.
  def plugins
    @plugins ||= Noosfero::Plugin::Manager.new(environment, self)
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def self.extended base
      CALLBACK_HOTSPOTS.each do |callback|
        if base.respond_to?(callback)
          base.class_eval do
            self.send callback do |object|
              current=self.class
              while current.included_modules.include? Noosfero::Plugin::HotSpot do
                callback_name = "#{current.name.underscore}_#{callback}_callback"
                plugins.dispatch(callback_name, object)
                current=current.superclass
              end
            end
          end
        end
      end
    end
  end
end
