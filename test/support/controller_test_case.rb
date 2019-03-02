
class ActionController::TestCase

  class_attribute :default_params
  self.default_params = {}

  def get(action, params = {}, session = {}, flash = {})
    params = self.default_params.merge(params)
    super action, params: params, session: session, flash: flash
  end

  def post(action, params = {}, session = {}, flash = {})
    params = self.default_params.merge(params)
    super action, params: params, session: session, flash: flash
  end

end

