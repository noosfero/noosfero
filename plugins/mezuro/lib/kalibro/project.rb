class Kalibro::Project < Kalibro::Model

  attr_accessor :id, :name, :description

  def self.all
    response = request("Project", :all_projects)[:project].to_a
    response = [] if response.nil?
    response.map {|project| new project}
  end

  def self.find(project_id)
    new request("Project", :get_project, :project_id => project_id)[:project]
  end

  def self.project_of(repository_id)
    new request("Project", :project_of, :repository_id => repository_id)[:project]
  end
=begin
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
=end

end
