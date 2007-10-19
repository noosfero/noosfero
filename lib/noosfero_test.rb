module NoosferoTest

  def get(path, parameters = nil, headers = nil)
    super(path, (parameters ? self.class.extra_parameters.merge(parameters) : self.class.extra_parameters) , headers)
  end

  def post(path, parameters = nil, headers = nil)
    super(path, (parameters ? self.class.extra_parameters.merge(parameters) : self.class.extra_parameters), headers)
  end


end
