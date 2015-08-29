require_dependency 'user'

class User

  has_many :oauth_auths, through: :person
  has_many :oauth_providers, through: :oauth_auths, source: :provider

  after_create :activate_oauth_user

  def activate_oauth_user
    self.activate if oauth_providers.present?
  end

  def password_required_with_oauth?
    password_required_without_oauth? && oauth_providers.empty?
  end

  alias_method_chain :password_required?, :oauth

  def make_activation_code_with_oauth
    oauth_providers.blank? ? make_activation_code_without_oauth : nil
  end

  alias_method_chain :make_activation_code, :oauth

end
