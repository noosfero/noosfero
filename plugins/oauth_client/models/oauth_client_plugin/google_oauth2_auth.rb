class OauthClientPlugin::GoogleOauth2Auth < OauthClientPlugin::Auth

  def image_url(size = nil)
    size = IMAGE_SIZES[size] || IMAGE_SIZES[:icon]
    "#{self.external_person_image_url}?sz=#{size}"
  end

  def profile_url
    "https://plus.google.com/#{self.external_person_uid}"
  end

  def settings_url
    "https://plus.google.com/u/0/settings"
  end
end
