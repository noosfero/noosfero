class MezuroPluginProfileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def module_result
    project_content = profile.articles.find(params[:id])
    module_result = project_content.module_result(params[:module_name])
    render :partial => 'content_viewer/module_result', :locals => { :module_result =>  module_result}
  end

  def project_result
    project_content = profile.articles.find(params[:id])
    project_result = project_content.project_result
    render :partial => 'content_viewer/project_result', :locals => { :project_result => project_result }
  end

  def project_state
    project_content = profile.articles.find(params[:id])
    project_content.project.state
    render :text => "READY"
  end

end
