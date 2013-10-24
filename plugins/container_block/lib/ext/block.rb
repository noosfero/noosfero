require_dependency 'block'

class Block
  
  def box_with_container_block_plugin
    box = box_without_container_block_plugin
    if box && box.owner.kind_of?(ContainerBlock) 
      box = box.owner.box
    end
    box
  end

  alias_method_chain :box, :container_block_plugin

end
