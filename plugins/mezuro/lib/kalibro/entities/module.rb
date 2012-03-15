class Kalibro::Entities::Module < Kalibro::Entities::Entity

  attr_accessor :name, :granularity

  def self.parent_names(name)
    path = []
    ancestors = []
    name.split(".").each do |token|
       path << token
       ancestors << path.join(".")
     end
     ancestors
  end

  def ancestor_names
    Kalibro::Entities::Module.parent_names(@name)
  end
end
