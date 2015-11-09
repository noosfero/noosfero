require_dependency 'profile'

Profile.descendants.each do |subclass|
  subclass.class_eval do

    has_many :oauth_auths, foreign_key: :profile_id, class_name: 'OauthClientPlugin::Auth', dependent: :destroy
    has_many :oauth_providers, through: :oauth_auths, source: :provider

  end
end
