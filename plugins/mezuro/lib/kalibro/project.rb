class Kalibro::Project < Kalibro::Model

  attr_accessor :name, :license, :description, :repository, :configuration_name, :state, :error

  def self.all_names
    request("Project", :get_project_names)[:project_name]
  end
  
  def self.find_by_name(project_name)
    begin
      attributes = request("Project", :get_project, :project_name => project_name)[:project]
      new attributes
    rescue Exception => error
      nil
    end
  end

  def self.destroy(project_name)
    request("Project", :remove_project, {:project_name => project_name})
  end

  def self.create (content)
    new({
      :name => content.name,
      :license => content.license,
      :description => content.description,
      :repository => {
        :type => content.repository_type,
        :address => content.repository_url
      }, 
      :configuration_name => content.configuration_name
    })
  end

  def save
    begin
      self.class.request("Project", :save_project, {:project => to_hash})
      true
    rescue Exception => error
      false
    end
  end

  def repository=(value)
    @repository = to_object(value, Kalibro::Repository)
  end

end

