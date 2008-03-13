class CategoryController < PublicController

  # view the summary of one category
  def view
    # TODO: load articles, documents, etc so the view can list them.
  end

  before_filter :load_category, :only => [ :view ]
  def load_category
    path = params[:path].join('/')
    @category = environment.categories.find_by_path(path)
    if @category.nil?
      render_not_found(path)
    end
  end

end
