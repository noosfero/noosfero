class MezuroPluginBaseToolController < MezuroPluginMyprofileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def choose_base_tool
    @configuration_content = profile.articles.find(params[:id])
    @base_tools = Kalibro::BaseTool.all_names
  end

  def choose_metric
    @configuration_content = profile.articles.find(params[:id])
    @base_tool = params[:base_tool]
    base_tool = Kalibro::BaseTool.find_by_name(@base_tool)
    @supported_metrics = base_tool.nil? ? [] : base_tool.supported_metrics 
  end

end
