class OauthClientPlugin::OauthExternalPerson < ExternalPerson

  before_save :add_timestamp

  has_one :oauth_auth, as: :profile, class_name: 'OauthClientPlugin::Auth', dependent: :destroy
  has_one :oauth_provider, through: :oauth_auth, source: :provider

  def avatar
      self.oauth_auth.image_url
  end

  def image
      OauthClientPlugin::OauthExternalPerson::Image.new(self.oauth_auth)
  end

  def public_profile_url
      self.oauth_auth.profile_url
  end

  def url
      self.oauth_auth.profile_url
  end

  def admin_url
      self.oauth_auth.settings_url
  end

  class OauthClientPlugin::OauthExternalPerson::Image < ExternalPerson::Image
    def initialize(oauth_auth)
      @oauth_auth = oauth_auth
    end

    def public_filename(size = nil)
      URI(@oauth_auth.image_url(size))
    end
  end

  protected
    def add_timestamp
      self.created_at = Time.now
    end
end
