class OauthClientPluginPublicController < PublicController

  skip_before_filter :login_required

  def callback
    auth = request.env["omniauth.auth"]
    auth_user = environment.users.where(email: auth.info.email).first
    if auth_user then login auth_user.person else signup auth end
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

  def login person
    provider = OauthClientPlugin::Provider.find(session[:provider_id])
    auth = person.oauth_auths.where(provider_id: provider.id).first
    auth ||= person.oauth_auths.create! profile: person, provider: provider, enabled: true
    if auth.enabled? && provider.enabled?
      self.current_user = person.user
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
