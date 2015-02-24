class OauthClientPluginPublicController < PublicController

  skip_before_filter :login_required

  def callback
    auth = request.env["omniauth.auth"]
    user = environment.users.find_by_email(auth.info.email)
    user ? login(user) : signup(auth)
  end

  def failure
    session[:notice] = _('Failed to login')
    redirect_to root_url
  end

  def destroy
    session[:user] = nil
    redirect_to root_url
  end

  protected

  def login(user)
    provider = OauthClientPlugin::Provider.find(session[:provider_id])
    user_provider = user.oauth_user_providers.find_by_provider_id(provider.id)
    unless user_provider
      user_provider = user.oauth_user_providers.create(:user => user, :provider => provider, :enabled => true)
    end
    if user_provider.enabled? && provider.enabled?
      session[:user] = user.id
    else
      session[:notice] = _("Can't login with #{provider.name}")
    end

    redirect_to :controller => :account, :action => :login
  end

  def signup(auth)
    login = auth.info.email.split('@').first
    session[:oauth_data] = auth
    name = auth.info.name
    name ||= auth.extra && auth.extra.raw_info ? auth.extra.raw_info.name : ''
    redirect_to :controller => :account, :action => :signup, :user => {:login => login, :email => auth.info.email}, :profile_data => {:name => name}
  end

end
