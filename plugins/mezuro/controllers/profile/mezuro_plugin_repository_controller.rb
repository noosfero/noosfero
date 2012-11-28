class MezuroPluginRepositoryController < MezuroPluginProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')
  
  def new_repository
    @project_content = profile.articles.find(params[:id])
    
    @repository_types = Kalibro::Repository.repository_types
    #@repository_type_select = []
    #repository_types.each do |repository_type|
    #  @repository_type_select.push [repository_type,repository_type]
    #end
    
    configurations = Kalibro::Configuration.all
    @configuration_select = []
    configurations.each do |configuration|
      @configuration_select.push [configuration.name,configuration.id] 
    end
  end
  
  def create_repository
    project_content = profile.articles.find(params[:id])
    project_content_name = project_content.name
    
    repository = Kalibro::Repository.new( params[:repository] )
    repository.save(project_content.project_id)
    
    if( repository.errors.empty? )
      redirect_to "/#{profile.identifier}/#{project_content_name.downcase.gsub(/\s/, '-')}"
    else
      redirect_to_error_page repository.errors[0].message
    end
  end
  
  def processing(repository_id)
    begin
      if Kalibro::Processing.has_ready_processing(repository_id)
        @processing ||= Kalibro::Processing.last_ready_processing_of(repository_id)
      else
        @processing = Kalibro::Processing.last_processing_of(repository_id)
      end
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @processing
  end

  def processing_with_date(repository_id, date)
    begin
      if Kalibro::Processing.has_processing_after(repository_id, date)
        @processing ||= Kalibro::Processing.first_processing_after(repository_id, date)
      elsif Kalibro::Processing.has_processing_before(repository_id, date)
        @processing ||= Kalibro::Processing.last_processing_before(repository_id, date)
      end
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @processing
  end

  def module_result(repository_id, date = nil)
    @processing ||= date.nil? ? processing(repository_id) : processing_with_date(repository_id, date)
    begin
      @module_result ||= Kalibro::ModuleResult.find(@processing.results_root_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
    @module_result
  end

  def result_history(module_result_id)
    begin
      @result_history ||= Kalibro::MetricResult.history_of(module_result_id)
    rescue Exception => error
      errors.add_to_base(error.message)
    end
  end
  
end
