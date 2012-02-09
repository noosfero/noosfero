class Kalibro::Entities::Project < Kalibro::Entities::Entity

	attr_accessor :name, :license, :description, :repository, :configuration_name, :state, :error

  def repository=(value)
    @repository = to_entity(value, Kalibro::Entities::Repository)
  end

  def error=(value)
    @error = to_entity(value, Kalibro::Entities::Error)
  end

end