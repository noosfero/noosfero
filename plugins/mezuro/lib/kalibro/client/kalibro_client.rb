class Kalibro::Client::KalibroClient
  
  def initialize
    @port = Kalibro::Client::Port.new('Kalibro')
  end

  def supported_repository_types
    @port.request(:get_supported_repository_types)[:repository_type].to_a
  end

  def process_project(project_name)
    @port.request(:process_project, {:project_name => project_name})
  end

  def self.process_project(project_name)
    new.process_project(project_name)
  end

end
