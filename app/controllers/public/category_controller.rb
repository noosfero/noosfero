class CategoryController < ApplicationController

  design :holder => 'environment'
  
  before_filter :load_default_enviroment
    
  def load_default_enviroment
    Environment.default
  end

  before_filter :load_category, :only => [ :view ]
  def load_category
    path = params[:path].join('/')
    @category = environment.categories.find_by_path(path)
    if @category.nil?
      render :text => ('No such category (%s).' % path), :status => 404
    end
  end

  # view the summary of one category
  def view
    # TODO: load articles, documents, etc so the view can list them.
  end

end
