class Kalibro::Client::KalibroClient

  def self.process_project(project_name)
    new.process_project(project_name)
  end
  
  def initialize
    @port = Kalibro::Client::Port.new('Kalibro')
  end

  def supported_repository_types
    @port.request(:get_supported_repository_types)[:repository_type].to_a
  end

  def process_project(project_name)
    @port.request(:process_project, {:project_name => project_name})
  end

  def self.process_project(project_name, days)
    if days.to_i.zero?
    	new.process_project(project_name)
  	else
  		new.process_periodically(project_name, days)
  	end
  end

	def process_periodically(project_name, period_in_days)
    @port.request(:process_periodically, {:project_name => project_name, :period_in_days => period_in_days})
  end

	def process_period(project_name)
    @port.request(:get_process_period, {:project_name => project_name})[:period]
  end

	def cancel_periodic_process(project_name)
    @port.request(:cancel_periodic_process, {:project_name => project_name})
  end

end
