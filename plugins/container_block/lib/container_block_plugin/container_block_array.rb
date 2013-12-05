module ContainerBlockPlugin::ContainerBlockArray

  def blocks_with_container_block_plugin(reload = false)
    blocks = blocks_without_container_block_plugin(reload)
    blocks.each { |block| blocks.concat(block.blocks) if block.kind_of?(ContainerBlockPlugin::ContainerBlock) }
  end

  def self.included(base)
    base.class_eval do
      alias_method_chain :blocks, :container_block_plugin
    end
  end

end
