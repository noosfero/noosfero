class BlockSweeper < ActiveRecord::Observer

  observe :block

  class << self
    include SweeperHelper

    # Expire block's all languages cache
    def expire_block(block)
      return if !block.environment
      regex = '-[a-z]*$'
      clean_ck = block.cache_key.gsub(/#{regex}/,'')

      block.environment.locales.keys.each do |locale|
        expire_timeout_fragment("#{clean_ck}-#{locale}")
      end
    end

    def expire_blocks(blocks)
      blocks.each { |block| expire_block(block) }
    end
  end

  def after_save(block)
    self.class.expire_block(block)
  end

end
