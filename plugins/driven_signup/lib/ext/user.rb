require_dependency 'user'

class User

  after_create :driven_signup_complete

  protected

  def driven_signup_complete
    return unless self.session and self.session.delete(:driven_signup)

    base_organization = self.environment.profiles.where(identifier: self.session.delete(:base_organization)).first
    return unless base_organization
    organization = base_organization

    if self.session.delete :find_suborganization
      members_limit = self.session.delete(:suborganization_members_limit).to_i || 50
      suborganizations = self.environment.profiles.
        where('identifier <> ?', base_organization.identifier).
        where('identifier LIKE ?', "#{base_organization.identifier}%").
        order('identifier ASC')
      pp suborganizations
      suborganizations.each do |suborganization|
        if suborganization.members.count < members_limit
          organization = suborganization
          break
        end
      end
    end

    if template = self.environment.profiles.where(identifier: self.session.delete(:user_template)).first
      self.person.articles.destroy_all
      self.person.apply_template template
    end

    # directly affiliate
    organization.affiliate self.person, Profile::Roles.member(self.environment.id)

    self.person.redirection_after_login = 'custom_url'
    self.person.custom_url_redirection = Noosfero::Application.routes.url_for organization.url
    self.person.save

    self.session[:after_signup_redirect_to] = organization.url
  end

end
