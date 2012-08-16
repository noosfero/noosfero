class Kalibro::ModuleNode < Kalibro::Model

  attr_accessor :module, :child

  def module=(value)
    @module = Kalibro::Module.to_object value
  end

  def child=(value)
    @child = Kalibro::ModuleNode.to_objects_array value
  end

  def children
    @child
  end

  def children=(children)
    @child = children
  end

end
