class CommentParagraphPluginAdminController < AdminController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index
    @settings = Noosfero::Plugin::Settings.new(environment, CommentParagraphPlugin, params[:settings])
    if request.post?
      @settings.save!
      session[:notice] = _('Settings successfuly saved')
    end
  end

end
