class CategoryController < ApplicationController

  before_filter :load_default_enviroment


  #FIXME This is not necessary because the application controller define the envrioment 
  # as the default holder
   
  design :holder => 'environment'
  
  def load_default_enviroment
    @environment = Environment.default
  end

  before_filter :load_category, :only => [ :view ]
  def load_category
    path = params[:path].join('/')
    @category = environment.categories.find_by_path(path)
    if @category.nil?
      render_not_found(path)
    end
  end

  # view the summary of one category
  def view
    # TODO: load articles, documents, etc so the view can list them.
  end

end
