class PublicAccessRestrictionPlugin < Noosfero::Plugin

  def self.plugin_name
    _('Public Access Restriction')
  end

  def self.plugin_description
    _('Restrict unauthenticated visitors to access any public profile, but the portal.')
  end

  def should_block?(user, environment, params, profile)
    params = params.with_indifferent_access
    profile = Profile[params[:profile]] unless profile
    not(
      user ||
      (profile && environment.is_portal_community?(profile)) ||
      params['controller'] == 'account' ||
      params['controller'] == 'home'
    )
  end

  def application_controller_filters
    me = self
    {
      type: 'before_filter',
      method_name: 'public_access_restriction',
      block: lambda do
        if me.should_block? user, environment, params, profile
          redirect_to controller: '/account', action: 'login'
        end
      end
    }
  end

end
