class Kalibro::Module < Kalibro::Model

  attr_accessor :name, :granularity

=begin
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
    self.class.parent_names(@name)
  end
=end

end
