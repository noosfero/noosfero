module ThemeLoaderHelper
  def current_theme
    @current_theme ||=
      begin
        if session[:theme]
          session[:theme]
        else
          # utility for developers: set the theme to 'random' in development mode and
          # you will get a different theme every request. This is interesting for
          # testing
          if Rails.env.development? && environment.theme == 'random'
            @random_theme ||= Dir.glob('public/designs/themes/*').map { |f| File.basename(f) }.rand
            @random_theme
          elsif Rails.env.development? && respond_to?(:params) && params[:theme] && File.exists?(Rails.root.join('public/designs/themes', params[:theme]))
            params[:theme]
          else
            if profile && !profile.theme.nil?
              profile.theme
            elsif environment
              environment.theme
            else
              if logger
                logger.warn("No environment found. This is weird.")
                logger.warn("Request environment: %s" % request.env.inspect)
                logger.warn("Request parameters: %s" % params.inspect)
              end

              # could not determine the theme, so return the default one
              'default'
            end
          end
        end
      end
  end

  def theme_path
    if session[:theme]
      '/user_themes/' + current_theme
    else
      '/designs/themes/' + current_theme
    end
  end
end
