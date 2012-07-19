class Kalibro::Project < Kalibro::Model

  attr_accessor :name, :license, :description, :repository, :configuration_name, :state, :error

  def self.all_names
    request("Project", :get_project_names)[:project_name]
  end

  def self.find_by_name(project_name)
    new request("Project", :get_project, :project_name => project_name)[:project]
  end

  def self.create(content)
    attributes = {
      :name => content.name,
      :license => content.license,
      :description => content.description,
      :repository => {
        :type => content.repository_type,
        :address => content.repository_url
      },
      :configuration_name => content.configuration_name
    }
    super attributes
  end

  def destroy
    self.class.request("Project", :remove_project, {:project_name => name})
  end

  def repository=(value)
    @repository = Kalibro::Repository.to_object value
  end

  def error=(value)
    @error = Kalibro::Error.to_object value
  end

  def process_project(days = '0')
    if days.to_i.zero?
      self.class.request("Kalibro", :process_project, {:project_name => name})
  	else
      self.class.request("Kalibro", :process_periodically, {:project_name => name, :period_in_days => days})
  	end
  end

	def process_period
    self.class.request("Kalibro", :get_process_period, {:project_name => name})[:period]
  end

	def cancel_periodic_process
    self.class.request("Kalibro", :cancel_periodic_process, {:project_name => name})
  end

end
