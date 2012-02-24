class Kalibro::Entities::Metric < Kalibro::Entities::Entity
  
  attr_accessor :name, :scope, :description, :id

  def initialize name, scope, description, id
    @name = name
    @scope = scope
    @description = description
    @id = id
  end

end
