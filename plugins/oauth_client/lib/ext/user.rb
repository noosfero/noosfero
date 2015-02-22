require_dependency 'user'

class User

  has_many :oauth_user_providers, :class_name => 'OauthClientPlugin::UserProvider'
  has_many :oauth_providers, :through => :oauth_user_providers, :source => :provider

  def password_required_with_oauth?
    password_required_without_oauth? && oauth_providers.empty?
  end

  alias_method_chain :password_required?, :oauth

  after_create :activate_oauth_user

  def activate_oauth_user
    unless oauth_providers.empty?
      activate
      oauth_providers.each do |provider|
        OauthClientPlugin::UserProvider.create!(:user => self, :provider => provider, :enabled => true)
      end
    end
  end

  def make_activation_code_with_oauth
    oauth_providers.blank? ? make_activation_code_without_oauth : nil
  end

  alias_method_chain :make_activation_code, :oauth

end
