class OauthClientPlugin::TwitterAuth < OauthClientPlugin::Auth

  IMAGE_SIZES = {
                 :big => "",
                 :thumb => "_bigger",
                 :portrait => "_normal",
                 :minor => "_normal",
                 :icon => "_mini"
                }

  def image_url(size = nil)
    size = IMAGE_SIZES[size] || IMAGE_SIZES[:icon]
    self.external_person_image_url.gsub("_normal", size)
  end

  def profile_url
    "https://twitter.com/#{self.profile.identifier}"
  end

  def settings_url
    "https://twitter.com/settings"
  end
end
