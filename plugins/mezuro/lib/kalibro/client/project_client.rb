class Kalibro::Client::ProjectClient

  def initialize
    @port = Kalibro::Client::Port.new('Project')
  end

  def save(project)
    @port.request(:save_project, {:project => project.to_hash})
  end

  def self.save(project)
    new.save(project)
  end

  def project_names
    @port.request(:get_project_names)[:project_name].to_a
  end

  def project(name)
    hash = @port.request(:get_project, {:project_name => name})[:project]
    Kalibro::Entities::Project.from_hash(hash)
  end

  def remove(project_name)
    @port.request(:remove_project, {:project_name => project_name})
  end

  def self.remove(project_name)
    new.remove(project_name)
  end
end
