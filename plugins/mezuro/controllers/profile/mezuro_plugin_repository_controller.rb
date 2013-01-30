class MezuroPluginRepositoryController < MezuroPluginProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
  
  def new
    @project_content = profile.articles.find(params[:id])

    @repository_types = Kalibro::Repository.repository_types
    
    configurations = Kalibro::Configuration.all
    configurations = [] if (configurations.nil?)
    @configuration_select = configurations.map do |configuration|
      [configuration.name,configuration.id] 
    end
  end
  
  def create
    project_content = profile.articles.find(params[:id])

    repository = Kalibro::Repository.new( params[:repository] )
    repository.save(project_content.project_id)
    
    if( repository.errors.empty? )
      repository.process
      redirect_to(repository_url(project_content))
    else
      redirect_to_error_page repository.errors[0].message
    end
  end

  def edit
    @project_content = profile.articles.find(params[:id])
    @repository_types = Kalibro::Repository.repository_types
    
    configurations = Kalibro::Configuration.all
    configurations = [] if (configurations.nil?)
    @configuration_select = configurations.map do |configuration|
      [configuration.name,configuration.id] 
    end

    @repository = @project_content.repositories.select{ |repository| repository.id.to_s == params[:repository_id] }.first
  end

  def update
    project_content = profile.articles.find(params[:id])
    
    repository = Kalibro::Repository.new( params[:repository] )
    repository.save(project_content.project_id)

    if( repository.errors.empty? )
      repository.process
      redirect_to(repository_url(project_content))
    else
      redirect_to_error_page repository.errors[0].message
    end
  end

  def show 
    @project_content = profile.articles.find(params[:id])
    @repository = @project_content.repositories.select{ |repository| repository.id.to_s == params[:repository_id] }.first
    @configuration_name = Kalibro::Configuration.configuration_of(@repository.id).name
  end

  def destroy
    project_content = profile.articles.find(params[:id])
    repository = project_content.repositories.select{ |repository| repository.id.to_s == params[:repository_id] }.first
    repository.destroy
    if( repository.errors.empty? )
      redirect_to project_content.view_url
    else
      redirect_to_error_page repository.errors[0].message
    end
  end
  
  def repository_url project_content
    url = project_content.view_url
    url[:controller] = controller_name
    url[:id] = project_content.id
    url[:repository_id] = params[:repository_id].to_i
    url[:action] = "show"
    url
  end
  
end
