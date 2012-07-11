class Kalibro::Kalibro < Kalibro::Model

  def self.repository_types
    request("Kalibro", :get_supported_repository_types)[:repository_type].to_a
  end

  def self.process_project(project_name, days = '0')
    if days.to_i.zero?
      request("Kalibro", :process_project, {:project_name => project_name})
  	else
      request("Kalibro", :process_periodically, {:project_name => project_name, :period_in_days => days})
  	end
  end

	def self.process_period(project_name)
    request("Kalibro", :get_process_period, {:project_name => project_name})[:period]
  end

	def self.cancel_periodic_process(project_name)
    request("Kalibro", :cancel_periodic_process, {:project_name => project_name})
  end
end
