# This module must be included by classes that contain Noosfero plugin
# hotspots.
#
# Classes that include this module *must* provide a method called
# <tt>environment</tt> which returns an intance of Environment. This
# Environment will be used to determine which plugins are enabled and therefore
# which plugins should be instantiated.
module Noosfero::Plugin::HotSpot

  # Returns an instance of Noosfero::Plugin::Manager.
  #
  # This which is intantiated on the first call and just returned in subsequent
  # calls.
  def plugins
    @plugins ||= Noosfero::Plugin::Manager.new(environment, self)
  end

end
