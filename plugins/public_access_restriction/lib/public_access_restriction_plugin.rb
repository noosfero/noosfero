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
    params = params.to_h.with_indifferent_access
    profile = Profile[params[:profile]] unless profile
    not(
      user ||
      (profile && environment.is_portal_community?(profile)) ||
      params['controller'] == 'account' ||
      params['controller'] == 'home' ||
      params['controller'] == 'national_regions' ||
      params['controller'] == 'public_access_restriction_plugin_public_page' ||
      linked_on_portal_news(environment, params, profile) ||
      show_newsletter?(environment, params, profile) ||
      newsletter_mail?(environment, params)
    )
  end

  def should_display_public_page?(params)
    params = params.to_h.with_indifferent_access
    profile = Profile[params[:profile]]
    settings = Noosfero::Plugin::Settings.new(profile, self.class) if profile
    settings.show_public_page.in? ["1", true] if settings
  end

  def application_controller_filters
    me = self
    {
      type: 'before_action',
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

  def control_panel_entries
    [PublicAccessRestrictionPlugin::ControlPanel::WelcomePage]
  end

  private

  def linked_on_portal_news(environment, params, profile)
    return false unless params['controller'] == 'content_viewer' && params['action'] == 'view_page'
    return false if params['page'].nil?
    article = profile.articles.find_by(path: params['page'])
    portal = environment.portal_community
    portal.articles.
      where(type: 'LinkArticle').
      where(reference_article_id: article.id).first.present?
  end

  def show_newsletter? environment, params, profile
    if environment.enabled_plugins.include?("NewsletterPlugin")
      newsletter = NewsletterPlugin::Newsletter.find_by(environment: environment.id)
      newsletter.blogs.find_by(profile: profile)
    end
  end

  def newsletter_mail? environment, params
    if environment.enabled_plugins.include?("NewsletterPlugin")
      params['controller'] == 'newsletter_plugin' && params['action'] == 'mailing'
    end
  end

end
