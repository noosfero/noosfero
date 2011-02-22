class Noosfero::Plugin::Context

  def initialize(controller)
    @controller = controller
  end

  # Here the developer should define the interface to important context
  # information from the controller to the plugins to access
  def profile
    @profile ||= @controller.send(:profile)
  end

  def request
    @request ||= @controller.send(:request)
  end

  def response
    @response ||= @controller.send(:response)
  end

  def environment
    @environment ||= @controller.send(:environment)
  end

  def params
    @params ||= @controller.send(:params)
  end

end
