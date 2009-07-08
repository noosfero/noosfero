class CategorySweeper < ActiveRecord::Observer
  observe :category
  include SweeperHelper

  def after_save(category)
    expire_fragment(category.environment.name + "_categories_menu")
  end

end
