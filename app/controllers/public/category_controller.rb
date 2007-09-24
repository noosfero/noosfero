class CategoryController < ApplicationController

  before_filter :load_category, :only => [ :view ]
  def load_category
    path = params[:path].join('/')
    @category = environment.categories.find_by_path(path)
  end

  # list categories
  def index
  end

  # view the summary of one category
  def view
  end

end
