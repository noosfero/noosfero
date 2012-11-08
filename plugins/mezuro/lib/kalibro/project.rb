class Kalibro::Project < Kalibro::Model

  attr_accessor :id, :name, :description

  def self.all
    response = request(:all_projects)[:project].to_a
    response = [] if response.nil?
    response.map {|project| new project}
  end

  def self.project_of(repository_id)
    new request(:project_of, :repository_id => repository_id)[:project]
  end

end
