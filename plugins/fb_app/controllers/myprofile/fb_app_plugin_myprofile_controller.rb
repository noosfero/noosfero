class FbAppPluginMyprofileController < OpenGraphPlugin::MyprofileController

  no_design_blocks

  before_filter :load_provider
  before_filter :load_auth

  def index
    if params[:tabs_added]
      @page_tabs = FbAppPlugin::PageTab.create_from_tabs_added params[:tabs_added], params[:page_tab]
      @page_tab = @page_tabs.first
      redirect_to @page_tab.facebook_url
    end
  end

  def show_login
    @status = params[:auth].delete :status
    @logged_auth = FbAppPlugin::Auth.new params[:auth]
    @logged_auth.fetch_user
    if @auth.connected?
      render partial: 'identity', locals: {auth: @logged_auth}
    else
      render nothing: true
    end
  end

  def save_auth
    @status = params[:auth].delete :status rescue FbAppPlugin::Auth::Status::Unknown
    if @status == FbAppPlugin::Auth::Status::Connected
      @auth.attributes = params[:auth]
      @auth.save! if @auth.changed?
    else
      @auth.destroy if @auth and @auth.persisted?
      @auth = new_auth
    end

    render partial: 'settings'
  end

  protected

  def load_provider
    @provider = FbAppPlugin.oauth_provider_for environment
  end

  def load_auth
    @auth = FbAppPlugin::Auth.where(profile_id: profile.id, provider_id: @provider.id).first
    @auth ||= new_auth
  end

  def new_auth
    FbAppPlugin::Auth.new profile: profile, provider: @provider
  end

  def context
    :fb_app
  end

end
