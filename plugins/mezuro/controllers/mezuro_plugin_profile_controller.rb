class MezuroPluginProfileController < ProfileController

  def metrics
    project_content = profile.articles.find(params[:id])
    module_name = params[:module_name]
    render :partial => 'content_viewer/module_result', :locals => { :module_result => project_content.module_result(module_name) }
  end

end
