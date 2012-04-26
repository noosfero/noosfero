class MezuroPluginProfileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def project_state
    content = profile.articles.find(params[:id])
    project = content.project
    state = project.error.nil? ? project.state : "ERROR"
    render :text => state
  end

  def project_error
    content = profile.articles.find(params[:id])
    project = content.project
    render :partial => 'content_viewer/project_error', :locals => { :project => project }
  end

  def project_result
    
    content = profile.articles.find(params[:id])
    date = params[:date]
    project_result = date.nil? ? content.project_result : content.get_date_result(date)
    project = content.project
    render :partial => 'content_viewer/project_result', :locals => { :project_result => project_result}
  end 	

  def module_result
    content = profile.articles.find(params[:id])
    date = params[:date]
    project_result = date.nil? ? content.project_result : content.get_date_result(date)
    module_result = content.module_result(params[:module_name])
    render :partial => 'content_viewer/module_result', :locals => { :module_result =>  module_result}
  end

  def project_tree
    content = profile.articles.find(params[:id])
    date = params[:date]
    project_result = date.nil? ? content.project_result : content.get_date_result(date)
    project_result = content.project_result
    source_tree = project_result.node_of(params[:module_name])
    render :partial =>'content_viewer/source_tree', :locals => { :source_tree => source_tree, :project_name => content.project.name}
  end
  
end
