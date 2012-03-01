class Kalibro::Entities::Module < Kalibro::Entities::Entity

  attr_accessor :name, :granularity

  def ancestor_names
    path = []
    ancestors = []
    @name.split(".").each do |token|
       path << token
       ancestors << path.join(".")
     end
     ancestors
  end
end
