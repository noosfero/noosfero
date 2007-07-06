class HomeController < ApplicationController

  def index
    #TODO this is a test case of owner
    @owner = User.find(1)
  end

def teste
    render :update  do |page|
      page.replace_html 'box_1', :partial => 'leo'
#'nem acredito'
#      page.replace_html 'completed_todos', :partial => 'completed_todos'
#      page.replace_html 'working_todos', :partial => 'working_todos'
    end

end
end
