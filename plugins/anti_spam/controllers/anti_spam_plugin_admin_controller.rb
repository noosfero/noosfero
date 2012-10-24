class AntiSpamPluginAdminController < AdminController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index
    @settings = AntiSpamPlugin::Settings.new(environment, params[:settings])
    if request.post?
      @settings.save!
      redirect_to :action => 'index'
    end
  end

end
