class Kalibro::Client::ProjectClient

  def self.project(project_name)
    new.project(project_name)
  end

  def self.save(project_content)
    project = create_project(project_content)
    new.save(project)
  end

  def self.remove(project_name)
    new.remove(project_name)
  end

  def self.create_project (project_content)
    project = Kalibro::Entities::Project.new
    project.name = project_content.name
    project.license = project_content.license
    project.description = project_content.description
    project.repository = create_repository(project_content)
    project.configuration_name = project_content.configuration_name
    project
  end

  def self.create_repository(project_content)
    repository = Kalibro::Entities::Repository.new
    repository.type = project_content.repository_type
    repository.address = project_content.repository_url
    repository
  end
  
  def initialize
    @port = Kalibro::Client::Port.new('Project')
  end

  def save(project)
    @port.request(:save_project, {:project => project.to_hash})
  end

  def project_names
    @port.request(:get_project_names)[:project_name].to_a
  end

  def project(project_name)
    hash = @port.request(:get_project, {:project_name => project_name})[:project]
    Kalibro::Entities::Project.from_hash(hash)
  end

  def remove(project_name)
    @port.request(:remove_project, {:project_name => project_name})
  end

end
