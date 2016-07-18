class OauthClientPluginPublicController < PublicController

  skip_before_filter :login_required

  def callback
    auth_data = request.env["omniauth.auth"]
    oauth_params = request.env["omniauth.params"]

    if oauth_params && oauth_params["action"] == "external_login"
      external_person_login(auth_data)
    else
      auth_user = environment.users.where(email: auth_data.info.email).first
      if auth_user then login(auth_user.person) else signup(auth_data) end
    end
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

  def external_person_login(auth_data)
    provider = OauthClientPlugin::Provider.find(session[:provider_id])

    user = User.new(email: auth_data.info.email, login: auth_data.info.name.to_slug)
    person = OauthClientPlugin::OauthExternalPerson.find_or_create_by(
        identifier: auth_data.info.nickname || user.login,
        name: auth_data.info.name,
        source: provider.site || auth_data.provider,
        email: user.email
    )
    user.external_person_id = person.id

    oauth_auth = person.oauth_auth
    oauth_data = { profile: person, provider: provider, enabled: true,
                   external_person_uid: auth_data.uid, external_person_image_url: auth_data.info.image }
    oauth_auth ||= OauthClientPlugin::Auth.create_for_strategy(provider.strategy, oauth_data)
    create_session(user, oauth_auth)
  end

  def signup(auth_data)
    session[:oauth_data] = auth_data
    username = auth_data.info.email.split('@').first
    name = auth_data.info.name
    name ||= auth_data.extra && auth_data.extra.raw_info ? auth_data.extra.raw_info.name : ''
    redirect_to :controller => :account, :action => :signup, :user => {:login => username, :email => auth_data.info.email}, :profile_data => {:name => name}
  end

  def login(person)
    auth = person.oauth_auths.find_or_create_by(profile: person,
                                                provider_id: session[:provider_id])
    create_session(person.user, auth)
  end

  def create_session(user, oauth_auth)
    provider = OauthClientPlugin::Provider.find(session[:provider_id])

    if oauth_auth.allow_login?
      self.current_user = user
    else
      session[:notice] = _("Can't login with %s") % provider.name
    end

    redirect_to :controller => :account, :action => :login
  end

end
