class Kalibro::Project < Kalibro::Model

  attr_accessor :name, :license, :description, :repository, :configuration_name, :state, :kalibro_error

  def self.all_names
    request("Project", :get_project_names)[:project_name]
  end

  def self.find_by_name(project_name)
    new request("Project", :get_project, :project_name => project_name)[:project]
  end

  def repository=(value)
    @repository = Kalibro::Repository.to_object value
  end

  def error=(value)
    @kalibro_error = Kalibro::Error.to_object value
  end

  def process_project(days = '0')
    begin
      if days.to_i.zero?
        self.class.request("Kalibro", :process_project, {:project_name => name})
    	else
        self.class.request("Kalibro", :process_periodically, {:project_name => name, :period_in_days => days})
    	end
    rescue Exception => exception
      add_error exception
    end
  end

	def process_period
	  begin
      self.class.request("Kalibro", :get_process_period, {:project_name => name})[:period]
    rescue Exception => exception
      add_error exception
    end
  end

	def cancel_periodic_process
	  begin
      self.class.request("Kalibro", :cancel_periodic_process, {:project_name => name})
    rescue Exception => exception
      add_error exception
    end
  end

end
