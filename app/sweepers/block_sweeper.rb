class BlockSweeper < ActiveRecord::Observer

  observe :block

  class << self
    include SweeperHelper

    def cache_key_regex(block)
      regex = '-[a-z]*$'
      clean_ck = block.cache_key.gsub(/#{regex}/,'')
      %r{#{clean_ck+regex}}
    end

    # Expire block's all languages cache
    def expire_block(block)
      expire_timeout_fragment(cache_key_regex(block))
    end

    def expire_blocks(blocks)
      blocks.each { |block| expire_block(block) }
    end
  end

  def after_save(block)
    self.class.expire_block(block)
  end

end
