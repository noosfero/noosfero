class Kalibro::Entities::ModuleNode < Kalibro::Entities::Entity

  attr_accessor :module, :child

  def module=(value)
    @module = to_entity(value, Kalibro::Entities::Module)
  end

  def module_name
    @module.name
  end

  def granularity
    @module.granularity
  end

  def child=(value)
    @child = to_entity_array(value, Kalibro::Entities::ModuleNode)
  end

  def children
    @child
  end

  def children=(children)
    @child = children
  end

end
