
class ActionController::TestCase

  class_attribute :default_params
  self.default_params = {}

  def get path, parameters = nil, session = nil, flash = nil
    super path, if parameters then self.default_params.merge parameters else self.default_params end, session, flash
  end

  def post path, parameters = nil, session = nil, flash = nil
    super path, if parameters then self.default_params.merge parameters else self.default_params end, session, flash
  end

end

