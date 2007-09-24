class CategoriesController < EnvironmentAdminController
  def index
    @categories = environment.top_level_categories
  end
end
