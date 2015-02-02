class ClassifyMembersPluginAdminController < PluginsController
  def index
    @settings ||= Noosfero::Plugin::Settings.new(
      environment, ClassifyMembersPlugin, params[:settings]
    )

    if request.post?
      @settings.save!
      redirect_to :controller => 'plugins', :action => 'index'
    end
  end
end
