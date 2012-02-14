class MezuroPluginProfileController < ProfileController

  def metrics
    project_content = profile.articles.find(params[:id])
    module_name = params[:module_name]
    render :partial => 'content_viewer/module_result', :locals => { :module_result => project_content.module_result(module_name) }
  end

  def autoreload
    page_content = profile.articles.find(params[:id])
    project_name = params[:project_name]
    render :partial => 'content_viewer/autoreload', :locals => { :project_result => page_content.project_result(project_name) }
  end
end
