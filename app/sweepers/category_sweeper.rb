class CategorySweeper < ActiveRecord::Observer
  observe :category
  include SweeperHelper

  def after_save(category)
    expire_blocks_cache(category.environment, [:category])

    # Needed for environments with application layout
    expire_fragment(category.environment.id.to_s + "_categories_menu")
  end

  def after_destroy(category)
    expire_blocks_cache(category.environment, [:category])
  end
end
