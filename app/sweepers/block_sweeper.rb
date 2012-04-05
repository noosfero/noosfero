class BlockSweeper < ActiveRecord::Observer

  include SweeperHelper
  observe :block

  def after_save(block)
    expire_fragment(block.cache_key)
  end

end
