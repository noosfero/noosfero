class MezuroPluginProfileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def module_result
    project_content = profile.articles.find(params[:id])
    module_result = project_content.module_result(params[:module_name])
    render :partial => 'content_viewer/module_result', :locals => { :module_result =>  module_result}
  end

  def autoreload
    @project_content = profile.articles.find(params[:id])
    render :partial => 'content_viewer/autoreload'
  end
end
