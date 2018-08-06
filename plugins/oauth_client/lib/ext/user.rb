require_dependency 'user'

class User

  has_many :oauth_auths, through: :person
  has_many :oauth_providers, through: :oauth_auths, source: :provider

  after_create :activate_oauth_user
  after_create :store_oauth_providers

  def initialize_with_oauth_client(attributes = {}, options = {})
    attributes ||= {}
    @oauth_providers = attributes.delete(:oauth_providers) || []
    initialize_without_oauth_client(attributes, options)
  end
  alias_method :initialize_without_oauth_client, :initialize
  alias_method :initialize, :initialize_with_oauth_client

  def store_oauth_providers
    @oauth_providers.each do |provider|
      self.person.oauth_auths.create!(profile: self.person, provider: provider, enabled: true)
    end
  end

  def activate_oauth_user
    self.activate! if oauth_providers.present? || @oauth_providers.present?
  end

  def password_required_with_oauth?
    password_required_without_oauth? && oauth_providers.empty? && @oauth_providers.blank?
  end

  alias_method :password_required_without_oauth?, :password_required
  alias_method :password_required, :password_required_with_oauth?

  def make_activation_codes_with_oauth
    @oauth_providers.blank? && oauth_providers.blank? ? make_activation_codes_without_oauth : nil
  end

  alias_method :make_activation_code_without_oauth, :make_activation
  alias_method :make_activation, :make_activation_code_with_oauth

end
