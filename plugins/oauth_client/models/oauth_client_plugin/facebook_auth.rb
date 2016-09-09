class OauthClientPlugin::FacebookAuth < OauthClientPlugin::Auth

  def image_url(size = nil)
    size = IMAGE_SIZES[size] || IMAGE_SIZES[:icon]
    "#{self.external_person_image_url}?width=#{size}"
  end

  def profile_url
    "https://www.facebook.com/#{self.external_person_uid}"
  end

  def settings_url
    "https://www.facebook.com/settings"
  end

end
