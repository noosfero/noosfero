class Kalibro::Project < Kalibro::Model

  attr_accessor :id, :name, :description

  def id=(value)
    @id = value.to_i
  end

  def self.all
    response = request(:all_projects)[:project]
    response = [] if response.nil?
    response = [response] if response.is_a?(Hash) 
    response.map {|project| new project}
  end
end
