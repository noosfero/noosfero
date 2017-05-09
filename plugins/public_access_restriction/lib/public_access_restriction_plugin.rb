class PublicAccessRestrictionPlugin < Noosfero::Plugin

  def self.plugin_name
    _('Public Access Restriction')
  end

  def self.plugin_description
    _('Restrict unauthenticated visitors to access any public profile, but the portal.')
  end

  def stylesheet?
    true
  end

  def should_block?(user, environment, params, profile)
    params = params.with_indifferent_access
    profile = Profile[params[:profile]] unless profile
    not(
      user ||
      (profile && environment.is_portal_community?(profile)) ||
      params['controller'] == 'account' ||
      params['controller'] == 'home' ||
      params['controller'] == 'public_access_restriction_plugin_public_page'
    )
  end

  def should_display_public_page?(params)
    params = params.with_indifferent_access
    profile = Profile[params[:profile]]
    settings = Noosfero::Plugin::Settings.new(profile, self.class) if profile
    settings.show_public_page.in? ["1", true] if settings
  end

  def application_controller_filters
    me = self
    {
      type: 'before_filter',
      method_name: 'public_access_restriction',
      block: lambda do
        if me.should_block? user, environment, params, profile
          if me.should_display_public_page?(params)
            redirect_to controller: 'public_access_restriction_plugin_public_page'
          else
            redirect_to controller: '/account', action: 'login'
          end
        end
      end
    }
  end

  def control_panel_buttons
    if context.profile.organization?
      {
        title: _('Public Welcome Page'),
        icon: 'welcome-page',
        url: {
          controller: 'public_access_restriction_plugin_page',
          action: 'index'
        }
      }
    end
  end

end
