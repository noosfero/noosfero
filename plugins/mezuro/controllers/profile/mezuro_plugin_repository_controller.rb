class MezuroPluginRepositoryController < MezuroPluginProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def new
    params_repository_form
  end

  def edit
    params_repository_form
    @repository = @project_content.repositories.select{ |repository| repository.id == params[:repository_id].to_i }.first
  end

  def save
    project_content = profile.articles.find(params[:id])
    repository = Kalibro::Repository.new( params[:repository] )

    if( repository.save )
      repository.process
      redirect_to(repository_url(project_content, repository.id))
    else
      redirect_to_error_page repository.errors[0].message
    end
  end

  def show 
    @project_content = profile.articles.find(params[:id])
    @repository = @project_content.repositories.select{ |repository| repository.id == params[:repository_id].to_i }.first
    @configuration_name = Kalibro::Configuration.find(@repository.configuration_id).name
  end

  def destroy
    project_content = profile.articles.find(params[:id])
    repository = Kalibro::Repository.new :id => params[:repository_id] 
    repository.destroy
    if( repository.errors.empty? )
      redirect_to project_content.view_url
    else
      redirect_to_error_page repository.errors[0].message
    end
  end

  private
  
  def repository_url(project_content, repository_id)
    url = project_content.view_url
    url[:controller] = controller_name
    url[:id] = project_content.id
    url[:repository_id] = repository_id
    url[:action] = "show"
    url
  end

  def params_repository_form
    @project_content = profile.articles.find(params[:id])
    @repository_types = Kalibro::Repository.repository_types
    
    configurations = Kalibro::Configuration.all
    configurations = [] if (configurations.nil?)
    @configuration_select = configurations.map do |configuration|
      [configuration.name,configuration.id] 
    end
  end

end
