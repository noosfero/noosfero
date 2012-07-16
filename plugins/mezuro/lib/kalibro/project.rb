class Kalibro::Project < Kalibro::Model

  attr_accessor :name, :license, :description, :repository, :configuration_name, :state, :error

  def self.all_names
    request("Project", :get_project_names)[:project_name]
  end
  
  def self.find_by_name(project_name)
    new request("Project", :get_project, :project_name => project_name)[:project]
  end

  def self.create(content)
    new({
      :name => content.name,
      :license => content.license,
      :description => content.description,
      :repository => {
        :type => content.repository_type,
        :address => content.repository_url
      }, 
      :configuration_name => content.configuration_name
    }).save
  end

  def destroy
    self.class.request("Project", :remove_project, {:project_name => name})
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
    @repository = Kalibro::Repository.to_object value
  end

end
