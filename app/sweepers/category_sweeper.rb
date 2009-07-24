class CategorySweeper < ActiveRecord::Observer
  observe :category
  include SweeperHelper

  def after_save(category)
    expire_fragment(category.environment.id.to_s + "_categories_menu")
  end

end
