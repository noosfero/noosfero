class SocialSharePrivacyPluginAdminController < AdminController
  append_view_path File.join(File.dirname(__FILE__) + '/../views')

  protect 'edit_environment_features', :environment

  include SocialSharePrivacyPluginHelper

  def index
    @settings = Noosfero::Plugin::Settings.new(environment, SocialSharePrivacyPlugin, params[:settings])
    @settings.networks ||= []

    @available_networks = social_share_privacy_networks.sort
    @settings.networks &= @available_networks
    @available_networks -= @settings.networks

    if request.post?
      begin
        @settings.save!
        session[:notice] = _('Option updated successfully.')
      rescue Exception => exception
        session[:notice] = _('Option wasn\'t updated successfully.')
      end
      redirect_to :controller => 'plugins', :action => 'index'
    end
  end

end
