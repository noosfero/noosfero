require 'omniauth/strategies/noosfero_oauth2'

class OauthClientPlugin < Noosfero::Plugin

  def self.plugin_name
    "Oauth Client Plugin"
  end

  def self.plugin_description
    _("Login with Oauth.")
  end

  def login_extra_contents
    plugin = self
    proc do
      render :partial => 'auth/oauth_login', :locals => {:providers => environment.oauth_providers.enabled}
    end
  end

  def signup_extra_contents
    plugin = self

    proc do
      if plugin.context.session[:oauth_data].present?
        render :partial => 'account/oauth_signup'
      else
        ''
      end
    end
  end

  PROVIDERS = {
    :facebook => {
      :name => 'Facebook'
    },
    :google_oauth2 => {
      :name => 'Google'
    },
    :noosfero_oauth2 => {
      :name => 'Noosfero'
    }
  }

  def stylesheet?
    true
  end

  Rails.configuration.to_prepare do
    OmniAuth.config.on_failure = OauthClientPluginPublicController.action(:failure)
  end

  Rails.application.config.middleware.use OmniAuth::Builder do
    PROVIDERS.each do |provider, options|
      setup = lambda { |env|
        request = Rack::Request.new(env)
        strategy = env['omniauth.strategy']

        Noosfero::MultiTenancy.setup!(request.host)
        domain = Domain.by_name(request.host)
        environment = domain.environment rescue Environment.default

        provider_id = request.params['id']
        provider_id ||= request.session['omniauth.params']['id'] if request.session['omniauth.params']
        provider = environment.oauth_providers.find(provider_id)
        strategy.options.merge! client_id: provider.client_id, client_secret: provider.client_secret
        strategy.options.merge! provider.options.symbolize_keys

        request.session[:provider_id] = provider_id
      }

      provider provider, :setup => setup,
        :path_prefix => '/plugin/oauth_client',
        :callback_path => "/plugin/oauth_client/public/callback/#{provider}",
        :client_options => { :connection_opts => { :proxy => ENV["OAUTH_HTTP_PROXY"] } }
    end

    unless Rails.env.production?
      provider :developer, :path_prefix => "/plugin/oauth_client", :callback_path => "/plugin/oauth_client/public/callback/developer"
    end
  end

  def account_controller_filters
    {
      :type => 'before_filter', :method_name => 'signup',
      :block => proc {
        auth = session[:oauth_data]

        if auth.present? && params[:user].present?
          params[:user][:oauth_providers] = [OauthClientPlugin::Provider.find(session[:provider_id])]
          if request.post? && auth.info.email != params[:user][:email]
            raise "Wrong email for oauth signup"
          end
        end
      }
    }
  end

end
