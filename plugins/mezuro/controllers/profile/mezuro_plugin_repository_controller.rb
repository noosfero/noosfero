#TODO terminar esse controler e seus testes funcionais
#TODO falta o destroy
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
      redirect_to "/#{profile.identifier}/#{project_content.name.downcase.gsub(/\s/, '-')}"
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
      redirect_to "/#{profile.identifier}/#{project_content.name.downcase.gsub(/\s/, '-')}"
    else
      redirect_to_error_page repository.errors[0].message
    end
  end

  def show
    project_content = profile.articles.find(params[:id])
    @project_name = project_content.name
    @repository = project_content.repositories.select{ |repository| repository.id == params[:repository_id].to_s }.first
    @configuration_name = Kalibro::Configuration.configuration_of(@repository.id).name
    @processing = Kalibro::Processing.processing_of(@repository.id)
  end

  def destroy
    project_content = profile.articles.find(params[:id])
    repository = project_content.repositories.select{ |repository| repository.id == params[:repository_id].to_s }.first
    repository.destroy
    if( repository.errors.empty? )
      redirect_to "/#{profile.identifier}/#{project_content.name.downcase.gsub(/\s/, '-')}"
    else
      redirect_to_error_page repository.errors[0].message
    end
  end
  
end
