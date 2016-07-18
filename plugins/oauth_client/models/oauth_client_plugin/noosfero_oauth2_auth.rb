class OauthClientPlugin::NoosferoOauth2Auth < OauthClientPlugin::Auth

  def image_url(size = "")
    URI.join("http://#{self.provider.client_options[:site]}/profile/#{self.profile.identifier}/icon/", size)
  end

  def profile_url
    "http://#{self.profile.source}/profile/#{self.profile.identifier}"
  end

  def settings_url
    "http://#{self.profile.source}/myprofile/#{self.profile.identifier}"
  end
end
