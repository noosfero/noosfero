class OauthProviderPlugin < Noosfero::Plugin

  def self.plugin_name
    "Oauth Provider Plugin"
  end

  def self.plugin_description
    _("Oauth Provider.")
  end

  def stylesheet?
    true
  end

  Doorkeeper.configure do
    orm :active_record

    resource_owner_authenticator do
      domain = Domain.find_by_name(request.host)
      environment = domain ? domain.environment : Environment.default
      environment.users.find_by_id(session[:user]) || redirect_to('/account/login')
    end

    admin_authenticator do
      domain = Domain.find_by_name(request.host)
      environment = domain ? domain.environment : Environment.default
      user = environment.users.find_by_id(session[:user])
      unless user && user.person.is_admin?(environment)
        redirect_to('/account/login')
      end
      user
    end

    default_scopes :public
  end

  Rails.configuration.to_prepare do
    Rails.application.routes.prepend do
      scope 'oauth_provider' do
        use_doorkeeper do
          controllers ({
            :applications => 'oauth_provider_applications',
            :authorized_applications => 'oauth_provider_authorized_applications',
            :authorizations => 'oauth_provider_authorizations'
          })
        end
      end
    end
  end

  SCOPE_TRANSLATION = {
    'public' => _('Access your public data')
  }

end
