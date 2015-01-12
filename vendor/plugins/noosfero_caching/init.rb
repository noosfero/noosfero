module NoosferoHttpCaching

  def self.included(c)
    c.send(:after_filter, :noosfero_set_cache)
    c.send(:after_filter, :noosfero_session_check)
  end

  def noosfero_set_cache
    return if logged_in?
    n = nil
    if profile
      unless request.path =~ /^\/myprofile/
        n = environment.profile_cache_in_minutes
      end
    else
      if request.path == '/'
        n = environment.home_cache_in_minutes
      else
        if params[:controller] != 'account' && !request.xhr? && request.path !~ /^\/admin/
          n = environment.general_cache_in_minutes
        end
      end
    end
    if n && response.status < 400
      expires_in n.minutes, :private => false, :public => true
    end
  end

  def noosfero_session_check
    return if (params[:controller] == 'account' && params[:action] != 'user_data')
    headers["X-Noosfero-Auth"] = (session[:user] != nil).to_s
  end

  class Middleware
    def initialize(app)
      @app = app
    end
    def call(env)
      status, headers, body = @app.call(env)
      if headers['X-Noosfero-Auth'] == 'false'
        headers['Set-Cookie'] = remove_unwanted_cookies(headers['Set-Cookie'])
        headers.delete('Set-Cookie') if headers['Set-Cookie'].blank?
      end
      headers.delete('X-Noosfero-Auth')
      [status, headers, body]
    end

    protected

    # filter off all cookies except for plugin-provided ones that are
    # path-specific (i.e path != "/").
    def remove_unwanted_cookies(set_cookie)
      return nil if set_cookie.nil?
      set_cookie.split(/\s*,\s*/).select do |c|
        c =~ /^_noosfero_plugin_\w+=/ && c =~ /path=\/\w+/
      end.join(', ')
    end

  end

end

unless Rails.env.development?
  middleware = Noosfero::Application.config.middleware
  ActionController::Base.send(:include, NoosferoHttpCaching)
  middleware.insert_before ::ActionDispatch::Cookies, NoosferoHttpCaching::Middleware
end
