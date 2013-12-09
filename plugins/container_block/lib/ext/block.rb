require_dependency 'block'

class Block
  def owner_with_container_block_plugin
    owner = owner_without_container_block_plugin
    owner.kind_of?(ContainerBlockPlugin::ContainerBlock) ? owner.owner : owner
  end

  alias_method_chain :owner, :container_block_plugin
end
