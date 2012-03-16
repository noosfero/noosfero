# This class defines the interface to important context information from the
# controller that can be accessed by plugins
class Noosfero::Plugin::Context

  def initialize(controller)
    @controller = controller
  end

  delegate :profile, :request, :response, :environment, :params, :session, :user, :logged_in?, :to => :controller

  protected

  attr_reader :controller

end
