module MetadataPlugin::UrlHelper

  def og_domain
    MetadataPlugin.config[:open_graph][:domain] rescue context.send(:environment).default_hostname
  end

  def og_url_for options
    options.delete :port
    options[:host] = self.og_domain
    url = Noosfero::Application.routes.url_helpers.url_for options
    url.html_safe
  end

  def og_profile_url profile
    # open_graph client don't like redirects, give the exact url
    if profile.home_page_id.present?
      # force profile identifier for custom domains and fixed host. see og_url_for
      profile.url.merge profile: profile.identifier
    else
      {controller: :profile, profile: profile.identifier}
    end
  end

end
