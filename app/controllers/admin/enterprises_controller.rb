class EnterprisesController < AdminController

  def index
    @enterprises = Enterprise.find(:all)
  end

end
