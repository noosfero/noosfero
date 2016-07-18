class OauthClientPlugin::GithubAuth < OauthClientPlugin::Auth

  def image_url(size = nil)
    size = IMAGE_SIZES[size] || IMAGE_SIZES[:icon]
    "#{self.external_person_image_url}&size=#{size}"
  end

  def profile_url
    "https://www.github.com/#{self.profile.identifier}"
  end

  def settings_url
    "https://www.github.com/settings"
  end
end
