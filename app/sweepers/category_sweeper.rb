class CategorySweeper < ActiveRecord::Observer
  observe :category
  include SweeperHelper

  def after_save(category)
    # expire_fragment(category.environment.id.to_s + "_categories_menu")
    expire_blocks_cache(category.environment, [:category])
  end

  def after_destroy(category)
    expire_blocks_cache(category.environment, [:category])
  end
end
