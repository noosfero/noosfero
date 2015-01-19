class AntiSpamPluginAdminController < PluginAdminController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index
    @settings = Noosfero::Plugin::Settings.new(environment, AntiSpamPlugin, params[:settings])
    if request.post?
      @settings.save!
      redirect_to :action => 'index'
    end
  end

end
