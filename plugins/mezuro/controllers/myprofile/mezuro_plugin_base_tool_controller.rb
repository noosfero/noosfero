class MezuroPluginBaseToolController < MezuroPluginMyprofileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def choose_metric
    @configuration_content = profile.articles.find(params[:id])
    @base_tools = Kalibro::BaseTool.all
  end

end
