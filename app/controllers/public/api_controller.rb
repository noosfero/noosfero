class ApiController < PublicController

  no_design_blocks

  helper_method :endpoints

  def index
  end

  def playground
  end

  private

  def endpoints
    Noosfero::API::API.endpoints(environment)
  end

end
