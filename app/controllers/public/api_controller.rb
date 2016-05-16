class ApiController < PublicController

  no_design_blocks

  helper_method :endpoints

  def index
  end

  def playground
  end

  private

  def endpoints
    Api::App.endpoints(environment)
  end

end
