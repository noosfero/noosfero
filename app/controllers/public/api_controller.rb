class ApiController < PublicController

  no_design_blocks

  def index
    @api = Noosfero::API.api_class
  end

  def playground
    @api = Noosfero::API.api_class
  end

end
