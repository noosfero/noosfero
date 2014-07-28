class SocialSharePrivacyPluginAdminController < AdminController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  def index
    available_networks = Dir[SocialSharePrivacyPlugin.root_path + 'public/javascripts/modules/*.js'].map { |entry| entry.split('/').last.gsub(/\.js$/,'') }
    @selected = environment.socialshare
    @tags = available_networks - @selected
    if request.post?
      networks = params[:networks].map{ |network| network.strip } if params[:networks]
      environment.socialshare = networks
      if environment.save
        session[:notice] = _('Saved the selected social buttons')
        redirect_to :controller => 'plugins', :action => 'index'
      end
    end
  end

end
