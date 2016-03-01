require_dependency 'profile'

class Profile

  has_many :oauth_auths, foreign_key: :profile_id, class_name: 'OauthClientPlugin::Auth', dependent: :destroy
  has_many :oauth_providers, through: :oauth_auths, source: :provider

end
