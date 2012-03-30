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

	def process_periodically(project_name, days)
		@port.request(:process_periodically, {:project_name => project_name, :period_in_days => days})
	end

  def self.process_project(project_name, days)
    if days.to_i.zero?
    	new.process_project(project_name)
  	else
  		new.process_periodically(project_name, days)
  	end
  end

end
