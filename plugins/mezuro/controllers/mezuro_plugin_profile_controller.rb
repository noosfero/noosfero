class MezuroPluginProfileController < ProfileController

  def metrics
    project = profile.articles.find(params[:id])
    module_name = params[:module_name]
    render :partial => 'content_viewer/module_result', :locals => { :module_result => project.module_result(module_name) }
  end

end
